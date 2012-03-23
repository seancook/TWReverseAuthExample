//
//    TWViewController.m
//    TWiOS5ReverseAuthExample
//
//    Copyright (c) 2012 Sean Cook
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to
//    deal in the Software without restriction, including without limitation the
//    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//    sell copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//    IN THE SOFTWARE.
//

#import "TWViewController.h"
#import "TWSignedRequest.h"
#import "OAuth+Additions.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#define TW_X_AUTH_MODE_KEY                  @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH         @"reverse_auth"
#define TW_X_AUTH_MODE_CLIENT_AUTH          @"client_auth"
#define TW_X_AUTH_REVERSE_PARMS             @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET            @"x_reverse_auth_target"
#define TW_X_AUTH_USERNAME                  @"x_auth_username"
#define TW_X_AUTH_PASSWORD                  @"x_auth_password"
#define TW_SCREEN_NAME                      @"screen_name"
#define TW_USER_ID                          @"user_id"
#define TW_OAUTH_URL_REQUEST_TOKEN          @"https://api.twitter.com/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN             @"https://api.twitter.com/oauth/access_token"

#define POP_ALERT(_W,_X) [[[UIAlertView alloc] initWithTitle:_W message:_X delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show]

@interface TWViewController()

- (BOOL)_checkForLocalCredentials;
- (BOOL)_checkForKeys;
- (void)_handleError:(NSError *)error forResponse:(NSURLResponse *)response;
- (void)_handleStep2Response:(NSString *)responseStr;

@property (nonatomic, strong) ACAccountStore *accountStore;
@end

@implementation TWViewController
@synthesize reverseAuthBtn = _reverseAuthBtn;

@synthesize accountStore = _accountStore;

- (void)showAlert:(NSString *)alert title:(NSString *)title
{
    //  This can be triggered from different threads, ensure that we keep it on the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        POP_ALERT(title, alert);
    });
}

- (BOOL)_checkForKeys
{
    BOOL resp = YES;

    if (![TWSignedRequest consumerKey] || ![TWSignedRequest consumerSecret]) {
        [self showAlert:@"You must add reverse auth-enabled keys to TWSignedRequest.m" title:@"Yikes"];
        resp = NO;
    }

    return resp;
}

- (BOOL)_checkForLocalCredentials
{
    BOOL resp = YES;
    if (![TWTweetComposeViewController canSendTweet]) {
        [self showAlert:@"Please configure a Twitter account in Settings." title:@"Yikes"];
        resp = NO;
    }

    return resp;
}

- (IBAction)performReverseAuth:(id)sender
{
    //  Check to make sure that the user has added his credentials
    if ([self _checkForKeys] && [self _checkForLocalCredentials]) {
        //
        //  Step 1)  Ask Twitter for a special request_token for reverse auth
        //
        NSURL *url = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];

        // "reverse_auth" is a required parameter
        NSDictionary *dict = [NSDictionary dictionaryWithObject:TW_X_AUTH_MODE_REVERSE_AUTH forKey:TW_X_AUTH_MODE_KEY];
        TWSignedRequest *signedRequest = [[TWSignedRequest alloc] initWithURL:url parameters:dict requestMethod:TWSignedRequestMethodPOST];

        [signedRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!data) {
                [self showAlert:@"Unable to receive a request_token." title:@"Yikes"];
                [self _handleError:error forResponse:response];
            }
            else {
                NSString *signedReverseAuthSignature = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                //
                //  Step 2)  Ask Twitter for the user's auth token and secret
                //           include x_reverse_auth_target=CK2 and x_reverse_auth_parameters=signedReverseAuthSignature parameters
                //
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                    NSDictionary *step2Params = [NSDictionary dictionaryWithObjectsAndKeys:[TWSignedRequest consumerKey], TW_X_AUTH_REVERSE_TARGET, signedReverseAuthSignature, TW_X_AUTH_REVERSE_PARMS, nil];
                    NSURL *authTokenURL = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
                    TWRequest *step2Request = [[TWRequest alloc] initWithURL:authTokenURL parameters:step2Params requestMethod:TWRequestMethodPOST];

                    //  Obtain the user's permission to access the store
                    //
                    //  NB: You *MUST* keep the ACAccountStore around for as long as you need an ACAccount around.  See WWDC 2011 Session 124 for more info.
                    self.accountStore = [[ACAccountStore alloc] init];
                    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

                    [self.accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error) {
                        if (!granted) {
                            [self showAlert:@"User rejected access to his/her account." title:@"Yikes"];
                        }
                        else {
                            // obtain all the local account instances
                            NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];

                            // we can assume that we have at least one account thanks to +[TWTweetComposeViewController canSendTweet], let's return it
                            [step2Request setAccount:[accounts objectAtIndex:0]];
                            [step2Request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                if (!responseData) {
                                    [self showAlert:@"Error occurred in Step 2.  Check console for more info." title:@"Yikes"];
                                    [self _handleError:error forResponse:response];
                                }
                                else {
                                    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                    [self _handleStep2Response:responseStr];
                                }
                            }];
                        }
                    }];
                });
            }
        }];
    }
}

- (void)_handleError:(NSError *)error forResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;

    NSLog(@"[Step Two Request Error]: %@", [error localizedDescription]);
    NSLog(@"[Step Two Request Error]: Response Code:%d \"%@\" ", [urlResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[urlResponse statusCode]]);
}

#define RESPONSE_EXPECTED_SIZE 4
- (void)_handleStep2Response:(NSString *)responseStr
{
    NSDictionary *dict = [NSURL ab_parseURLQueryString:responseStr];

    // We are expecting a response dict of the format:
    //
    // {
    //     "oauth_token" = ...
    //     "oauth_token_secret" = ...
    //     "screen_name" = ...
    //     "user_id" = ...
    // }

    if ([dict count] == RESPONSE_EXPECTED_SIZE) {
        [self showAlert:[NSString stringWithFormat:@"User: %@\nUser ID: %@", [dict objectForKey:TW_SCREEN_NAME], [dict objectForKey:TW_USER_ID]] title:@"Success!"];
        NSLog(@"The user's info for your server:\n%@", dict);
    }
    else {
        [self showAlert:@"The response doesn't seem correct.  Please check the console." title:@"Hmm..."];
        NSLog(@"The user's info for your server:\n%@", dict);
    }
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload
{
    [self setReverseAuthBtn:nil];
    [super viewDidUnload];
}

@end
