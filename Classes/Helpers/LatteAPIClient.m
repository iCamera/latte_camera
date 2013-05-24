//
//  luxeysLatteAPIClient.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/13/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LatteAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "UIDeviceHardware.h"

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

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];

    UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    [self setDefaultHeader:@"Latte-version" value:majorVersion];
    [self setDefaultHeader:@"Latte-ios" value:[[UIDevice currentDevice] systemVersion]];
    [self setDefaultHeader:@"Latte-device" value:[device platformString]];
    [self setDefaultHeader:@"Latte-language" value:language];
    
    return self;
}

@end
