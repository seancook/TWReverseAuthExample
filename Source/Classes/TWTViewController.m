//
//    TWTViewController.m
//    ReverseAuthExample
//
//    Copyright (c) 2011-2015 Sean Cook
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

@import Accounts;

#import <OAuthCore/OAuth+Additions.h>
#import "TWTAPIManager.h"
#import "TWTSignedPOSTRequest.h"
#import "TWTViewController.h"

#define ERROR_TITLE_MSG @"Whoa, there cowboy"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in Settings.app to use this demo."
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS @"You need to add your Twitter app keys to Info.plist to use this demo.\n\nPlease see README.md for more info."
#define ERROR_OK @"OK"

#define ONE_FOURTH_OF(_X) floorf(0.25f * _X)
#define THREE_FOURTHS_OF(_X) floorf(3 * ONE_FOURTH_OF(_X))

@interface TWTViewController()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWTAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) UIButton *reverseAuthBtn;

@end

@implementation TWTViewController

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
        _apiManager = [[TWTAPIManager alloc] init];
    }
    return self;
}

- (void)loadView
{
    CGRect appFrame = [UIScreen mainScreen].bounds;

    CGRect buttonFrame = appFrame;
    buttonFrame.origin.y = 0.75f * appFrame.size.height;
    buttonFrame.size.height = 44.0f;
    buttonFrame = CGRectInset(buttonFrame, 20, 0);

    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    view.backgroundColor = [UIColor colorWithWhite:0.502f alpha:1.f];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter.png"]];
    [view addSubview:imageView];
    [imageView sizeToFit];
    imageView.center = view.center;

    CGRect imageFrame = imageView.frame;
    imageFrame.origin.y = 0.25f * appFrame.size.height;
    imageView.frame = imageFrame;

    _reverseAuthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reverseAuthBtn setTitle:@"Perform Token Exchange" forState:UIControlStateNormal];
    [_reverseAuthBtn addTarget:self action:@selector(performReverseAuth:) forControlEvents:UIControlEventTouchUpInside];
    [_reverseAuthBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    _reverseAuthBtn.titleLabel.font = [UIFont systemFontOfSize:24.f];
    _reverseAuthBtn.frame = buttonFrame;
    _reverseAuthBtn.enabled = NO;

    [view addSubview:_reverseAuthBtn];

    self.view = view;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _refreshTwitterAccounts];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshTwitterAccounts) name:ACAccountStoreDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIActionSheetDelegate

- (void)_accountSelected:(NSUInteger)selectedAccountIndex
{
    ACAccount *selectedAccount = _accounts[selectedAccountIndex];
    [_apiManager performReverseAuthForAccount:selectedAccount withHandler:^(NSData *responseData, NSError *error) {
        if (responseData) {
            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
            NSString *lined = [parts componentsJoinedByString:@"\n"];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self _displayAlertWithMessage:lined title:@"Success!"];
            });
        }
        else {
            NSLog(@"Reverse Auth process failed. Error returned was: %@\n", error.localizedDescription);
        }
    }];
}

#pragma mark - Private

- (void)_displayAlertWithMessage:(NSString *)message title:(NSString *)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:ERROR_OK style:UIAlertActionStyleDefault handler:NULL]];
    [self presentViewController:alert animated:YES completion:NULL];
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
    if (![TWTAPIManager hasAppKeys]) {
        [self _displayAlertWithMessage:ERROR_NO_KEYS title:ERROR_TITLE_MSG];
    }
    else if (![TWTAPIManager isLocalTwitterAccountAvailable]) {
        [self _displayAlertWithMessage:ERROR_NO_ACCOUNTS title:ERROR_TITLE_MSG];
    }
    else {
        [self _obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    self->_reverseAuthBtn.enabled = YES;
                }
                else {
                    [self _displayAlertWithMessage:ERROR_PERM_ACCESS title:ERROR_TITLE_MSG];
                }
            });
        }];
    }
}

- (void)_obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [_accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:^(BOOL granted, NSError *error) {
        if (granted) {
            self->_accounts = [self->_accountStore accountsWithAccountType:twitterType];
        }
        block(granted);
    }];
}

/**
 *  Handles the button press that initiates the token exchange.
 *
 *  We check the current configuration inside -[UIViewController viewDidAppear].
 */
- (void)performReverseAuth:(id)sender
{
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Choose an Account" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSUInteger i = 0; i < [_accounts count]; i++) {
        ACAccount *acct = _accounts[i];
        NSString *accountTitle = [NSString stringWithFormat:@"@%@", acct.username];
        [sheet addAction:[UIAlertAction actionWithTitle:accountTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self _accountSelected:i];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:sheet animated:YES completion:NULL];
}

@end
