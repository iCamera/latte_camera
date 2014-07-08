//
//  luxeysLatteAPIClient.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/13/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"

//static NSString * const kLatteAPIBaseURLString = @"http://192.168.2.118:5000/api/";


@interface LatteAPIv2Client : AFHTTPRequestOperationManager

+ (LatteAPIv2Client *)sharedClient;

@end
