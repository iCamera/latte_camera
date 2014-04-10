//
//  luxeysLatteAPIClient.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/13/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LatteAPIClient.h"
#import "UIDeviceHardware.h"
#import "LXAppDelegate.h"

@implementation LatteAPIClient

+ (LatteAPIClient *)sharedClient {
    static LatteAPIClient *_sharedClient = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[LatteAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kLatteAPIBaseURLString]];
        if (![kLatteAPIBaseURLString isEqualToString:@"http://latte.la/api/"]) {
            [_sharedClient.requestSerializer setAuthorizationHeaderFieldWithUsername:@"luxeys" password:@"13579"];
        }
        
        NSOperationQueue *operationQueue = _sharedClient.operationQueue;
        [_sharedClient.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [operationQueue setSuspended:NO];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"ConnectedInternet"
                     object:_sharedClient];
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"NoConnection"
                     object:_sharedClient];
                default:
                    [operationQueue setSuspended:YES];
                    break;
            }
        }];
    });
    
    return _sharedClient;
}

- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ([app getToken]) {
        [params setObject:[app getToken] forKey:@"token"];
    }
    
    return [super GET:URLString parameters:params success:success failure:failure];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ([app getToken]) {
        [params setObject:[app getToken] forKey:@"token"];
    }
    
    return [super POST:URLString parameters:params success:success failure:failure];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	// [self setDefaultHeader:@"Accept" value:@"application/json"];
    

    UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [self.requestSerializer setValue:majorVersion forHTTPHeaderField:@"Latte-version"];
    [self.requestSerializer setValue:build forHTTPHeaderField:@"Latte-build"];
    [self.requestSerializer setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"Latte-ios"];
    [self.requestSerializer setValue:[device platformString] forHTTPHeaderField:@"Latte-device"];
    [self.requestSerializer setValue:language forHTTPHeaderField:@"Latte-language"];
    [self.requestSerializer setValue:majorVersion forHTTPHeaderField:@"Latte-timezone"];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"%d", [timeZone secondsFromGMT]] forHTTPHeaderField:@"Latte-version"];
    
    return self;
}

@end
