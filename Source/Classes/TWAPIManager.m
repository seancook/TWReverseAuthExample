//
//    TWAPIManager.m
//    TWiOSReverseAuthExample
//
//    Copyright (c) 2012 Sean Cook
//
//    Permission is hereby granted, free of charge, to any person obtaining a
//    copy of this software and associated documentation files (the
//    "Software"), to deal in the Software without restriction, including
//    without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to permit
//    persons to whom the Software is furnished to do so, subject to the
//    following conditions:
//
//    The above copyright notice and this permission notice shall be included
//    in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
//    NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//    OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
//    USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "OAuth+Additions.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"

typedef void(^TWAPIHandler)(NSData *data, NSError *error);

@implementation TWAPIManager

/**
 *  Returns true if there are local Twitter accounts available for use.
 *
 *  Both iOS5 and iOS6 provide convenience methods to check if accounts are
 *  available locally.  Here, we just call the method that is available at
 *  run-time.
 */
+ (BOOL)isLocalTwitterAccountAvailable
{
    //  checks to see if we have Social.framework
    if ([SLComposeViewController class]) {
        return [SLComposeViewController
                isAvailableForServiceType:SLServiceTypeTwitter];
    }
    else {
        return [TWTweetComposeViewController canSendTweet];
    }
}

/**
 *  Returns a generic self-signing request that can be used to perform Twitter
 *  API requests.
 *
 *  @param  The URL of the endpoint to retrieve
 *  @dict   The API parameters to include with the request
 *  @requestMethod  The HTTP method to use
 */
- (id<GenericTwitterRequest>)requestWithUrl:(NSURL *)url
                                 parameters:(NSDictionary *)dict
                              requestMethod:(SLRequestMethod )requestMethod
{
    NSParameterAssert(url);
    NSParameterAssert(dict);
    NSParameterAssert(requestMethod);

    if ([SLRequest class]) {
        return (id<GenericTwitterRequest>)
        [SLRequest requestForServiceType:SLServiceTypeTwitter
                           requestMethod:requestMethod
                                     URL:url
                              parameters:dict];
    }
    else {
        return (id<GenericTwitterRequest>)
        [[TWRequest alloc] initWithURL:url
                            parameters:dict
                         requestMethod:requestMethod];
    }
}

/**
 *  Performs Reverse Auth for the given account.
 *
 *  Responsible for dispatching the result of the call, either sucess or error.
 *
 *  @param account  The local account for which we wish to exchange tokens
 *  @param handler  The block to call upon completion.  Will be called on the
 *                  main thread.
 */
- (void)performReverseAuthForAccount:(ACAccount *)account
                         withHandler:(TWAPIHandler)handler
{
    NSParameterAssert(account);
    [self _step1WithCompletion:^(NSData *data, NSError *error) {
        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil, error);
            });
        }
        else {
            NSString *signedReverseAuthSignature =
            [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            [self _step2WithAccount:account
                          signature:signedReverseAuthSignature
                         andHandler:^(NSData *responseData, NSError *error) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 handler(responseData, error);
                             });
                         }];
        }
    }];
}

#define TW_API_ROOT                  @"https://api.twitter.com"
#define TW_X_AUTH_MODE_KEY           @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH  @"reverse_auth"
#define TW_X_AUTH_MODE_CLIENT_AUTH   @"client_auth"
#define TW_X_AUTH_REVERSE_PARMS      @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET     @"x_reverse_auth_target"
#define TW_OAUTH_URL_REQUEST_TOKEN   TW_API_ROOT "/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN      TW_API_ROOT "/oauth/access_token"

/**
 *  The second stage of Reverse Auth.
 *
 *  In this step, we send our signed authorization header to Twitter in a
 *  request that is signed by iOS.
 *
 *  @param account The local account for which we wish to exchange tokens
 *  @param signedReverseAuthSignature   The Authorization: header returned from
 *                                      a successful step 1
 *  @param completion   The block to call when finished.  Can be called on any
 *                      thread.
 */
- (void)_step2WithAccount:(ACAccount *)account
                signature:(NSString *)signedReverseAuthSignature
               andHandler:(TWAPIHandler)completion
{
    NSParameterAssert(account);
    NSParameterAssert(signedReverseAuthSignature);

    NSDictionary *step2Params = [NSDictionary
                                 dictionaryWithObjectsAndKeys:
                                 [TWSignedRequest consumerKey],
                                 TW_X_AUTH_REVERSE_TARGET,
                                 signedReverseAuthSignature,
                                 TW_X_AUTH_REVERSE_PARMS,
                                 nil];
    NSURL *authTokenURL = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
    id<GenericTwitterRequest> step2Request =
    [self requestWithUrl:authTokenURL
              parameters:step2Params
           requestMethod:SLRequestMethodPOST];

    [step2Request setAccount:account];
    [step2Request performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         dispatch_async(dispatch_get_global_queue
                        (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            completion(responseData, error);
                        });
     }];
}

/**
 *  The first stage of Reverse Auth.
 *
 *  In this step, we sign and send a request to Twitter to obtain an
 *  Authorization: header which we will use in Step 2.
 *
 *  @param completion   The block to call when finished.  Can be called on any
 *                      thread.
 */
- (void)_step1WithCompletion:(TWAPIHandler)completion
{
    NSURL *url = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];
    NSDictionary *dict = [NSDictionary
                          dictionaryWithObject:TW_X_AUTH_MODE_REVERSE_AUTH
                          forKey:TW_X_AUTH_MODE_KEY];
    TWSignedRequest *step1Request = [[TWSignedRequest alloc]
                                     initWithURL:url
                                     parameters:dict
                                     requestMethod:TWSignedRequestMethodPOST];

    [step1Request performRequestWithHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
         dispatch_async(dispatch_get_global_queue
                        (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            completion(data, error);
                        });
     }];
}

@end
