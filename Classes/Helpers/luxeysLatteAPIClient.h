//
//  luxeysLatteAPIClient.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/13/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"

@interface luxeysLatteAPIClient : AFHTTPClient

+ (luxeysLatteAPIClient *)sharedClient;

@end
