//
//  luxeysLatteAPIClient.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/13/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LatteAPIClient.h"
#import "AFJSONRequestOperation.h"

@implementation LatteAPIClient

+ (LatteAPIClient *)sharedClient {
    static LatteAPIClient *_sharedClient = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[LatteAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kLatteAPIBaseURLString]];
        #ifdef DEBUG
        [_sharedClient setAuthorizationHeaderWithUsername:@"luxeys" password:@"13579"];
        #endif
        
        [_sharedClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"NoConnection"
                     object:_sharedClient];
                    
                    break;
                default:
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"ConnectedInternet"
                     object:_sharedClient];
                    
                    break;
            }
        }];
    });
    
    return _sharedClient;
}

//- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
//    [super postPath:path parameters:parameters success:success failure:failure];
//}
//
//- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
//    [super getPath:path parameters:parameters success:success failure:failure];
//}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
//    [request setValue:@"" forHTTPHeaderField:@"Latte-ios"];
//    [request setValue:@"" forHTTPHeaderField:@"Latte-version"];
//    [request setValue:@"" forHTTPHeaderField:@"Latte-device"];
    return request;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end
