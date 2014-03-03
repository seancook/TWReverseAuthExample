//
//  ViewController.m
//  Sample
//
//  Created by John Gazzini on 3/2/14.
//  Copyright (c) 2014 John Gazzini. All rights reserved.
//

#import "ViewController.h"
#import "SuperParseTwitter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [SuperParseTwitter logInWithView:self.view Block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            [self sayHello];
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            [self sayHello];
        } else {
            NSLog(@"User logged in with Twitter!");
            [self sayHello];
        }     
    }];
}

- (void)sayHello {
    NSLog(@"Hello!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
