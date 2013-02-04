//
//  LXRootBuilder.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/02/04.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXRootBuilder.h"

@implementation LXRootBuilder

- (void)updateObject:(id)element withPropertiesFrom:(NSDictionary *)dict {
    for (NSString *key in dict.allKeys){
        if ([key isEqualToString:@"type"] || [key isEqualToString:@"sections"]|| [key isEqualToString:@"elements"])
            continue;
        
        id value = [dict valueForKey:key];
        [QRootBuilder trySetProperty:key onObject:element withValue:value localized:NO];
    }
}

@end
