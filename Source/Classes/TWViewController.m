//
//    TWViewController.m
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
#import <Twitter/Twitter.h>
#import "OAuth+Additions.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"
#import "TWViewController.h"

@interface TWViewController()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) UIButton *reverseAuthBtn;

@end

@implementation TWViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
        _apiManager = [[TWAPIManager alloc] init];
    }
    return self;
}

- (void)loadView
{
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;

    CGRect buttonFrame = appFrame;
    buttonFrame.origin.y = floorf(0.75f * appFrame.size.height);
    buttonFrame.size.height = 44.0f;
    buttonFrame = CGRectInset(buttonFrame, 20, 0);

    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    [view setBackgroundColor:[UIColor colorWithWhite:0.502 alpha:1.000]];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:
                              [UIImage imageNamed:@"twitter.png"]];
    [view addSubview:imageView];
    [imageView sizeToFit];
    imageView.center = view.center;

    CGRect imageFrame = imageView.frame;
    imageFrame.origin.y = floorf(0.25f * appFrame.size.height);
    imageView.frame = imageFrame;

    _reverseAuthBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_reverseAuthBtn setTitle:@"Perform Token Exchange"
                     forState:UIControlStateNormal];
    [_reverseAuthBtn addTarget:self
                        action:@selector(performReverseAuth:)
              forControlEvents:UIControlEventTouchUpInside];
    _reverseAuthBtn.frame = buttonFrame;
    _reverseAuthBtn.enabled = NO;
    [_reverseAuthBtn setTitleColor:[UIColor blackColor]
                          forState:UIControlStateNormal];
    [view addSubview:_reverseAuthBtn];

    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshTwitterAccounts];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshTwitterAccounts)
     name:ACAccountStoreDidChangeNotification
     object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != (actionSheet.numberOfButtons - 1)) {
        [_apiManager
         performReverseAuthForAccount:_accounts[buttonIndex]
         withHandler:^(NSData *responseData, NSError *error) {
             if (responseData) {
                 NSString *responseStr = [[NSString alloc]
                                          initWithData:responseData
                                          encoding:NSUTF8StringEncoding];

                 NSArray *parts = [responseStr
                                   componentsSeparatedByString:@"&"];

                 NSString *lined = [parts componentsJoinedByString:@"\n"];

                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc]
                                           initWithTitle:@"Success!"
                                           message:lined
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                     [alert show];
                 });
             }
             else {
                 NSLog(@"Error!\n%@", [error localizedDescription]);
             }
         }];
    }
}

#pragma mark - Private

- (void)refreshTwitterAccounts
{
    //  Get access to the user's Twitter account(s)
    [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                _reverseAuthBtn.enabled = YES;
            }
            else {
                NSLog(@"You were not granted access to the Twitter accounts.");
            }
        });
    }];
}

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [_accountStore
                                  accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];

    ACAccountStoreRequestAccessCompletionHandler handler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }

        block(granted);
    };

    //  This method changed in iOS6.  If the new version isn't available, fall
    //  back to the original (which means that we're running on iOS5+).
    if ([_accountStore
         respondsToSelector:@selector(requestAccessToAccountsWithType:
                                      options:
                                      completion:)]) {
             [_accountStore requestAccessToAccountsWithType:twitterType
                                                    options:nil
                                                 completion:handler];
         }
    else {
        [_accountStore requestAccessToAccountsWithType:twitterType
                                 withCompletionHandler:handler];
    }
}

- (void)performReverseAuth:(id)sender
{
    if ([TWAPIManager isLocalTwitterAccountAvailable]) {
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Choose an Account"
                                delegate:self
                                cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil];

        for (ACAccount *acct in _accounts) {
            [sheet addButtonWithTitle:acct.username];
        }

        [sheet addButtonWithTitle:@"Cancel"];
        [sheet setDestructiveButtonIndex:[_accounts count]];
        [sheet showInView:self.view];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"No Accounts"
                              message:@"Please configure a Twitter "
                              "account in Settings.app"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
