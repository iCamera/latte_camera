//
//  LuxeysObject.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/02.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LuxeysObject : NSObject

+ (NSMutableArray *)mutableArrayFromDictionary:(NSDictionary *)aDictionary withKey:(NSString *)aKey;
+ (NSObject *)instanceFromDictionary:(NSDictionary *)aDictionary;

@end
