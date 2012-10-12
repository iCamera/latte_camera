//
//  luxeysLatteAPIClient.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/13/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LatteAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kLatteAPIBaseURLString = @"http://192.168.3.1:5000/";

@implementation LatteAPIClient

+ (LatteAPIClient *)sharedClient {
    static LatteAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[LatteAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kLatteAPIBaseURLString]];
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
    
    return self;
}

@end
