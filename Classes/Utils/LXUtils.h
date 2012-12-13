//
//  luxeysImageUtils.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

#import "User.h"


@interface LXUtils : NSObject

+ (NSInteger)heightFromWidth:(CGFloat)newwidth width:(CGFloat)width height:(CGFloat)height;
+ (NSString *)timeDeltaFromNow:(NSDate *)aDate;
+ (NSDate *)dateFromJSON:(NSString *)aDate;
+ (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location;
+ (NSString *)dateToString:(NSDate*)aDate;
+ (NSString *)stringFromNotify:(NSDictionary *)notify;

@end
