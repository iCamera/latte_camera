//
//  luxeysLatteAPIClient.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/13/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LatteAPIv2Client.h"
#import "UIDeviceHardware.h"
#import "LXAppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation LatteAPIv2Client

+ (LatteAPIv2Client *)sharedClient {
    static LatteAPIv2Client *_sharedClient = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[LatteAPIv2Client alloc] initWithBaseURL:[NSURL URLWithString:kLatteAPIv2BaseURLString]];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions: NSJSONReadingMutableContainers];
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        if (![kLatteAPIv2BaseURLString isEqualToString:@"http://latte.la/api2/"]) {
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

- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(AFHTTPRequestOperation *, id))success
                        failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
    return [super GET:URLString parameters:parameters success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
        DLog(@"%@", error.description);
    }];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                         success:(void (^)(AFHTTPRequestOperation *, id))success
                         failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
    return [super POST:URLString parameters:parameters success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
        DLog(@"%@", error.description);
    }];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    

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
    [self.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)[timeZone secondsFromGMT]] forHTTPHeaderField:@"Latte-version"];
    
    return self;
}

@end
