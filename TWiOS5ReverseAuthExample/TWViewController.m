//
//    TWViewController.m
//    TWiOS5ReverseAuthExample
//
//    Copyright (c) 2011 Sean Cook
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
#define TW_OAUTH_URL_REQUEST_TOKEN          @"https://api.twitter.com/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN             @"https://api.twitter.com/oauth/access_token"

#define POP_ALERT(_X) [[[UIAlertView alloc] initWithTitle:@"Whoopsie" message:_X delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show]

@interface TWViewController()
    @property (nonatomic, strong) ACAccountStore *accountStore;
@end

@implementation TWViewController

@synthesize accountStore = _accountStore;

- (void)showAlert:(NSString *)alert
{
    //  This can be triggered from different threads, ensure that we keep it on the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        POP_ALERT(alert);            
    });
}

- (BOOL)checkForLocalCredentials
{
    if (![TWTweetComposeViewController canSendTweet]) {
        [self showAlert:@"Please configure a Twitter account in Settings."];
        return NO;
    } 
    return YES;
}

- (void)performReverseAuth
{   
    // we can't do anything unless we've got local credentials
    if (![self checkForLocalCredentials]) return;
    
    //  
    //  Step 1)  Ask Twitter for a special request_token for reverse auth
    //
    NSURL *url = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // "reverse_auth" is a required parameter
    [dict setValue:TW_X_AUTH_MODE_REVERSE_AUTH forKey:TW_X_AUTH_MODE_KEY];
    
    TWSignedRequest *signedRequest = [[TWSignedRequest alloc] initWithURL:url parameters:dict requestMethod:TWSignedRequestMethodPOST];
    
    [signedRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data == nil) {
            [self showAlert:@"Unable to receive a request_token."];
        } else {             

            //
            //  Step 2)  Ask Twitter for the user's auth token and secret
            //           include x_reverse_auth_target=CK2 and x_reverse_auth_parameters=S parameters
            //           
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *S = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary *step2Params = [[NSMutableDictionary alloc] init];
                [step2Params setValue:[TWSignedRequest consumerKey] forKey:TW_X_AUTH_REVERSE_TARGET];
                [step2Params setValue:S forKey:TW_X_AUTH_REVERSE_PARMS];            
                
                NSURL *url2 = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
                TWRequest *stepTwoRequest = [[TWRequest alloc] initWithURL:url2 parameters:step2Params requestMethod:TWRequestMethodPOST];
                
                //  Obtain the user's permission to access the store
                //
                //  NB: You *MUST* keep the ACAccountStore around for as long as you need an ACAccount around.  See WWDC 2011 Session 124 for more info.
                self.accountStore = [[ACAccountStore alloc] init];
                ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                
                [self.accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error) {
                    if (!granted) {
                        [self showAlert:@"User rejected access to his/her account."];
                    } else {
                        // obtain all the local account instances
                        NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
                        
                        // we can assume that we have at least one account thanks to +canSendTweet, let's return it
                        [stepTwoRequest setAccount:[accounts objectAtIndex:0]];
                        
                        [stepTwoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                            NSDictionary *dict = [NSURL ab_parseURLQueryString:responseStr];
                            
                            // if everything worked...
                            NSLog(@"The user's info for your server:\n%@", dict);
                        }];
                    } 
                }];
            });
        }
    }];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performReverseAuth];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
