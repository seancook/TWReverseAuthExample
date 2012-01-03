//
//  TWSignedRequest.m
//  TWiOS5ReverseAuthExample
//
//  Created by Sean Cook (@theSeanCook) on 9/15/11.
//  Copyright (c) 2011 Sean Cook. All rights reserved.
//

#import "TWSignedRequest.h"
#import "OAuthCore.h"

#define TW_HTTP_METHOD_GET @"GET"
#define TW_HTTP_METHOD_POST @"POST"
#define TW_HTTP_METHOD_DELETE @"DELETE"
#define TW_HTTP_HEADER_AUTHORIZATION @"Authorization"

//  Important:  1) Your keys must be registered with Twitter to enable reverse_auth endpoint
//              2) You should obfuscate keys and secrets in your apps before shipping!

#warning You must enter your consumer key and secret for this demo to work
#define CONSUMER_SECRET @""
#define CONSUMER_KEY @""

@interface TWSignedRequest()

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSDictionary *parameters;
@property (readonly, nonatomic) TWSignedRequestMethod method;

- (NSURLRequest *)buildRequest;

@end

@implementation TWSignedRequest
@synthesize url = _url;
@synthesize parameters = _parameters;
@synthesize method = _method;

- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters requestMethod:(TWSignedRequestMethod)requestMethod;
{
    self = [super init];
    if (self) {
        _url = url;
        _parameters = parameters;
        _method = requestMethod;
    }
    return self;
}

- (NSURLRequest *)buildRequest
{
    NSAssert(_url, @"You can't build a request without an URL");
             
    NSString *method;
    
    switch (self.method) {
        case TWSignedRequestMethodPOST:
            method = TW_HTTP_METHOD_POST;
            break;
        case TWSignedRequestMethodDELETE:
            method = TW_HTTP_METHOD_DELETE;
            break;
        case TWSignedRequestMethodGET:
        default:
            method = TW_HTTP_METHOD_GET;
    }
    
    //  Build a parameter string from our parameters
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramsAsString appendFormat:@"%@=%@&", key, obj];
    }];
    
    //  Obtain the authorization header that we want to attach to our request
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorizationHeader = OAuthorizationHeader(self.url, method, bodyData, [TWSignedRequest consumerKey], [TWSignedRequest consumerSecret], nil, nil);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url];
    [request setHTTPMethod:method];
    [request setValue:authorizationHeader forHTTPHeaderField:TW_HTTP_HEADER_AUTHORIZATION];
    [request setHTTPBody:bodyData];
    
    return request;
}

- (void)performRequestWithHandler:(TWSignedRequestHandler)handler 
{
    NSAssert(handler, @"You must pass a handler to this method");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:[self buildRequest] returningResponse:&response error:&error];  
        handler(data, response, error);          
    });
}

// OBFUSCATE YOUR KEYS!
+ (NSString *)consumerKey 
{
    NSAssert([CONSUMER_KEY length] > 0, @"Dude, seriously.  Enter your consumer key.");
    return CONSUMER_KEY;
}

// OBFUSCATE YOUR KEYS!
+ (NSString *)consumerSecret
{
    NSAssert([CONSUMER_SECRET length] > 0, @"Dude, seriously.  Enter your consumer secret.");
    return CONSUMER_SECRET;
}

@end
