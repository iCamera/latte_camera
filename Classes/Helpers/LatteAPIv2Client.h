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
//static NSString * const kLatteAPIv2BaseURLString = @"http://dev-latte.luxeys.co.jp/api2/";
static NSString * const kLatteAPIv2BaseURLString = @"http://local-latte.la/api/";
//static NSString * const kLatteAPIv2BaseURLString = @"https://latte.la/api/";
#else
static NSString * const kLatteAPIv2BaseURLString = @"http://latte.la/api2/";
//static NSString * const kLatteAPIBaseURLString = @"http://beta.latte.la/api/";
#endif

//static NSString * const kLatteAPIBaseURLString = @"http://192.168.2.118:5000/api/";


@interface LatteAPIv2Client : AFHTTPRequestOperationManager

+ (LatteAPIv2Client *)sharedClient;

@end
