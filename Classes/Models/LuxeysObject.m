//
//  LuxeysObject.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/02.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LuxeysObject.h"

@implementation LuxeysObject

+ (NSMutableArray *)mutableArrayFromDictionary:(NSDictionary *)aDictionary withKey:(NSString *)aKey {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (NSDictionary *obj in [aDictionary objectForKey:aKey])
        [ret addObject:[self instanceFromDictionary:obj]];
    return ret;
}

+ (NSObject *)instanceFromDictionary:(NSDictionary *)aDictionary {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
