//
//  LXSocketIO.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/8/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"

@interface LXSocketIO : SocketIO<SocketIODelegate>

+ (instancetype)sharedClient;

@end
