//
//    TWTSignedRequest.m
//    ReverseAuthExample
//
//    Copyright (c) 2011-2014 Sean Cook
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

#import "OAuthCore.h"
#import "TWTSignedRequest.h"

#define TW_HTTP_METHOD_GET @"GET"
#define TW_HTTP_METHOD_POST @"POST"
#define TW_HTTP_METHOD_DELETE @"DELETE"
#define TW_HTTP_HEADER_AUTHORIZATION @"Authorization"
#define TW_CONSUMER_KEY @"TWITTER_CONSUMER_KEY"
#define TW_CONSUMER_SECRET @"TWITTER_CONSUMER_SECRET"

#define REQUEST_TIMEOUT_INTERVAL 8

static NSString *gTWConsumerKey;
static NSString *gTWConsumerSecret;

@interface TWTSignedRequest()
{
    NSURL *_url;
    NSDictionary *_parameters;
    TWTSignedRequestMethod _signedRequestMethod;
    NSOperationQueue *_signedRequestQueue;
}

@end

@implementation TWTSignedRequest

- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters requestMethod:(TWTSignedRequestMethod)requestMethod
{
    self = [super init];
    if (self) {
        _url = url;
        _parameters = parameters;
        _signedRequestMethod = requestMethod;
        _signedRequestQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (NSURLRequest *)_buildRequest
{
    NSString *method;
    
    switch (_signedRequestMethod) {
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
    
    //  Build our parameter string
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [_parameters enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
         [paramsAsString appendFormat:@"%@=%@&", key, obj];
     }];
    
    //  Create the authorization header and attach to our request
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorizationHeader = OAuthorizationHeader(_url, method, bodyData, [TWTSignedRequest consumerKey], [TWTSignedRequest consumerSecret], _authToken, _authTokenSecret);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
    [request setTimeoutInterval:REQUEST_TIMEOUT_INTERVAL];
    [request setHTTPMethod:method];
    [request setValue:authorizationHeader forHTTPHeaderField:TW_HTTP_HEADER_AUTHORIZATION];
    [request setHTTPBody:bodyData];
    
    return request;
}

- (void)performRequestWithHandler:(TWTSignedRequestHandler)handler
{
    NSURLRequest *request = [self _buildRequest];
    [NSURLConnection sendAsynchronousRequest:request queue:_signedRequestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        handler(data, response, connectionError);
    }];
}

// OBFUSCATE YOUR KEYS!
+ (NSString *)consumerKey
{
    if (!gTWConsumerKey) {
        NSAssert(gTWConsumerKey, @"You must call [TWSTSignedRequest setConsumerSecret:] before trying to make a request");
    }
    
    return gTWConsumerKey;
}

// OBFUSCATE YOUR KEYS!
+ (NSString *)consumerSecret
{
    if (!gTWConsumerSecret) {
        NSAssert(gTWConsumerSecret, @"You must call [TWSTSignedRequest setConsumerSecret:] before trying to make a request");
    }
    
    return gTWConsumerSecret;
}

+ (void)setConsumerKey:(NSString*)consumerKey {
    gTWConsumerKey = consumerKey;
}

+ (void)setConsumerSecret:(NSString *)consumerSecret {
    gTWConsumerSecret = consumerSecret;
}

@end
