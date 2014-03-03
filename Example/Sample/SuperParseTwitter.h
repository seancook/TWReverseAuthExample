//
//  SuperParseTwitter.h
//  Sample
//
//  Created by John Gazzini on 3/2/14.
//  Copyright (c) 2014 John Gazzini.
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

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef void (^ LoginBlock)(PFUser *user, NSError *error);

@interface SuperParseTwitter : NSObject

//For most people, this method will work fine. It presents the UIActionSheet in the application's main window.
+ (void)logInWithBlock:(LoginBlock)newLoginBlock;

// You should ensure that you obfuscate your keys before shipping
+ (NSString *)consumerKey;
+ (NSString *)consumerSecret;


//For weird people, or people doing weird things with the views, this method lets you specify which view to present the UIActionSheet in.
+ (void)logInWithView:(UIView *)newView Block:(LoginBlock)newLoginBlock;

@end
