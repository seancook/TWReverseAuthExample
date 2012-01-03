//
//  TWAppDelegate.m
//  TWiOS5ReverseAuthExample
//
//  Created by Sean Cook (@theSeanCook) on 9/15/11.
//  Copyright (c) 2011 Sean Cook. All rights reserved.
//

#import "TWAppDelegate.h"
#import "TWViewController.h"
#import <Twitter/Twitter.h>

@implementation TWAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[TWViewController alloc] initWithNibName:@"TWViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
