//
//  luxeysImageUtils.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface luxeysUtils : NSObject

+ (float)heightFromWidth:(float)newwidth width:(float)width height:(float)height;
+ (NSString *)timeDeltaFromNow:(NSDate *)aDate;
+ (NSDate *)dateFromJSON:(NSString *)aDate;

@end
