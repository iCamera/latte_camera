//
//  luxeysImageUtils.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

@interface luxeysUtils : NSObject

+ (NSInteger)heightFromWidth:(CGFloat)newwidth width:(CGFloat)width height:(CGFloat)height;
+ (NSString *)timeDeltaFromNow:(NSDate *)aDate;
+ (NSDate *)dateFromJSON:(NSString *)aDate;
+ (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location;

@end
