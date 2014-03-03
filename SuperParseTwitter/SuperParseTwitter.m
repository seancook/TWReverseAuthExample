//
//  SuperParseTwitter.m
//  Sample
//
//  Created by John Gazzini on 3/2/14.
//  Copyright (c) 2014 John Gazzini
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

#import "SuperParseTwitter.h"
#import "TWAPIManager.h"
#import <Accounts/Accounts.h>


@interface SuperParseTwitter () <UIActionSheetDelegate>

@property (nonatomic, copy)LoginBlock loginBlock;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) UIButton *reverseAuthBtn;

- (void)startLoginProcessWithBlock:(LoginBlock)newLoginBlock andView:(UIView *)newView;

@end


@implementation SuperParseTwitter

#pragma - Public
+ (void)logInWithView:(UIView *)newView Block:(LoginBlock)newLoginBlock {
    //First: create an actual instance of this class (inception-style):
    SuperParseTwitter *loginInstance = [SuperParseTwitter sharedManager];
    
    //Then, tell that something to login:
    [loginInstance startLoginProcessWithBlock:newLoginBlock andView:newView];
}

+ (void)logInWithBlock:(LoginBlock)newLoginBlock {
    [SuperParseTwitter logInWithView:[[UIApplication sharedApplication].delegate window] Block:newLoginBlock];
}

// OBFUSCATE YOUR KEYS!
+ (NSString *)consumerKey
{
    //TODO: ENTER YOUR CONSUMER KEY HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#warning Enter your Twitter consumer key here!
    return nil;
}

// OBFUSCATE YOUR KEYS!
+ (NSString *)consumerSecret
{
    //TODO: ENTER YOUR CONSUMER SECRET HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#warning Enter your Twitter consumer secret here!
    return nil;
}




#pragma - Private
- (void)startLoginProcessWithBlock:(LoginBlock)newLoginBlock andView:(UIView *)newView {
    _view = newView;
    _accountStore = [[ACAccountStore alloc] init];
    _apiManager = [[TWAPIManager alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshTwitterAccounts) name:ACAccountStoreDidChangeNotification object:nil];
    _loginBlock = newLoginBlock;    //persisting that block is the only reason this ActualLoginClass exists
    [self _refreshTwitterAccounts];
}
/**
 *  Checks for the current Twitter configuration on the device / simulator.
 *
 *  First, we check to make sure that we've got keys to work with inside Info.plist (see README)
 *
 *  Then we check to see if the device has accounts available via +[TWAPIManager isLocalTwitterAccountAvailable].
 *
 *  Next, we ask the user for permission to access his/her accounts.
 *
 *  Upon completion, the button to continue will be displayed, or the user will be presented with a status message.
 */
- (void)_refreshTwitterAccounts
{
    NSLog(@"Refreshing Twitter Accounts \n");
    
    if (![TWAPIManager hasAppKeys]) {
        NSLog(@"Error! You need to set your keys in SuperParseTwitter.m");
    }
    else if (![TWAPIManager isLocalTwitterAccountAvailable]) {
        //revert to the old web-view login as a fallback
        [self oldLogin];
    }
    else {
        [self _obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self performReverseAuth:nil];
                }
                else {
                    //If the user decides to make things difficult
                    [self oldLogin];
                    NSLog(@"You were not granted access to the Twitter accounts.");
                }
            });
        }];
    }
}

- (void)_obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    [_accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:handler];
}

/**
 *  Handles the button press that initiates the token exchange.
 *
 *  We check the current configuration inside -[UIViewController viewDidAppear].
 */
- (void)performReverseAuth:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (ACAccount *acct in _accounts) {
        [sheet addButtonWithTitle:acct.username];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:self.view];
}




//This here is a fallback, just incase the user doesn't have any Twitter accounts on their phone.
//Or if the user has Twitter accounts on their phone with invalid credentials.
//Or if the user denies the app permission to use their Twitter account, but still wants to use the app with their Twitter account.
//Or if the user is clever, and finds some other way to make reverse auth fail.
- (void)oldLogin {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACAccountStoreDidChangeNotification object:nil];
    static Boolean showingLogin = NO;   //Only 1 login webview thing should be on the screen at once.
    if (!showingLogin) {
        showingLogin = YES;
        [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
            showingLogin = NO;
            _loginBlock(user, error);
        }];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [_apiManager performReverseAuthForAccount:_accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
            if (responseData) {
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                //NSLog(@"Reverse Auth process returned: %@", responseStr);
                
                NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                if ([parts count] < 4) {
                    [self oldLogin];
                }
                else {
                    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[parts count]];
                    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:[parts count]];
                    for (NSString *string in parts) {
                        NSArray *subParts = [string componentsSeparatedByString:@"="];
                        //NSLog(@"%@ : %@", subParts[0], subParts[1]);
                        if ([subParts count] > 1) {
                            [objects addObject:subParts[1]];
                            [keys addObject:subParts[0]];
                        }
                    }
                    
                    //NSString *lined = [parts componentsJoinedByString:@"\n"];
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSString *oauth_token = [dict objectForKey:@"oauth_token"];
                        NSString *oauth_token_secret = [dict objectForKey:@"oauth_token_secret"];
                        NSString *screen_name = [dict objectForKey:@"screen_name"];
                        NSString *user_id = [dict objectForKey:@"user_id"];
                        
                        [PFTwitterUtils logInWithTwitterId:user_id screenName:screen_name authToken:oauth_token authTokenSecret:oauth_token_secret block:^(PFUser *user, NSError *error) {
                            [[NSNotificationCenter defaultCenter] removeObserver:self name:ACAccountStoreDidChangeNotification object:nil];
                            _loginBlock(user, error);
                        }];
                        
                    });
                }
            }
            else {
                NSLog(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
            }
        }];
    }
    else {
        [self oldLogin];
    }
}


+(id)sharedManager {
    static SuperParseTwitter *sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[self alloc] init];
    });
    return sharedDataManager;
}
- (id)init {
    if (self = [super init]) {
        //Default Values go here!
    }
    return self;
}



@end