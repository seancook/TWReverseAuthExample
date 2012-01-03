//
//  TWSignedRequest.h
//  TWiOS5ReverseAuthExample
//
//  Created by Sean Cook (@theSeanCook) on 9/15/11.
//  Copyright (c) 2011 Sean Cook. All rights reserved.
//

#import <Foundation/Foundation.h>

enum TWSignedRequestMethod {
    TWSignedRequestMethodGET,
    TWSignedRequestMethodPOST,
    TWSignedRequestMethodDELETE
};

typedef enum TWSignedRequestMethod TWSignedRequestMethod;

typedef void(^TWSignedRequestHandler)(NSData *data, NSURLResponse *response, NSError *error);

@interface TWSignedRequest : NSObject

// Creates a new request 
- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters requestMethod:(TWSignedRequestMethod)requestMethod;

// Perform the request, and notify handler of results
- (void)performRequestWithHandler:(TWSignedRequestHandler)handler;

// Keys are behind getters; we should ensure that we've obfuscated before shipping
+ (NSString *)consumerKey;
+ (NSString *)consumerSecret;
@end
