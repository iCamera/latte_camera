//
//  luxeysLatteAPIClient.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/13/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"


#ifdef DEBUG
//static NSString * const kLatteAPIBaseURLString = @"http://dev-latte.luxeys.co.jp/api";
static NSString * const kLatteAPIBaseURLString = @"http://local-latte.la/api/";
//static NSString * const kLatteAPIBaseURLString = @"https://latte.la/api/";
#else
static NSString * const kLatteAPIBaseURLString = @"http://latte.la/api/";
//static NSString * const kLatteAPIBaseURLString = @"http://beta.latte.la/api/";
#endif

//static NSString * const kLatteAPIBaseURLString = @"http://192.168.2.118:5000/api/";


@interface LatteAPIClient : AFHTTPRequestOperationManager

+ (LatteAPIClient *)sharedClient;

@end
