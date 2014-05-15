//
//  luxeysImageUtils.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <CoreLocation/CoreLocation.h>
@class Feed, Picture, User;

typedef NS_ENUM(NSInteger, NotifyKind) {
    kNotifyKindComment = 1,
    kNotifyKindLike = 2,
    kNotifyKindFollow = 3,
    kNotifyKindTargetUpdate = 10,
} ;

typedef NS_ENUM(NSInteger, NotifyTarget) {
    kNotifyTargetPicture = 1,
    kNotifyTargetUser = 2,
    kNotifyTargetComment = 41,
} ;

#define kGlobalAnimationSpeed 0.25

@interface LXUtils : NSObject

+ (NSInteger)heightFromWidth:(CGFloat)newwidth width:(CGFloat)width height:(CGFloat)height;
+ (NSString *)timeDeltaFromNow:(NSDate *)aDate;
+ (NSDate *)dateFromJSON:(NSString *)aDate;
+ (NSDate *)dateFromJSON:(NSString *)aDate timezone:(BOOL)timezone;
+ (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location;
+ (NSString *)dateToString:(NSDate*)aDate;

+ (NSString *)stringFromNotify:(NSDictionary *)notify;
+ (CGSize)newSizeOfPicture:(Picture *)picture withWidth:(CGFloat)width;
+ (Picture *)picFromPicID:(long)picID of:(NSArray *)feeds;
+ (Feed *)feedFromPicID:(long)picID of:(NSArray *)feeds;
+ (void)toggleLike:(UIButton*)sender ofPicture:(Picture*)pic;
+ (void)toggleLike:(UIButton*)sender ofPicture:(Picture*)pic setCount:(UILabel*)labelCount;
+ (void)globalShadow:(UIView*)view;
+ (void)setNationalityOfUser:(User *)user forImage:(UIImageView*)imageNationality nextToLabel:(UILabel*)label;
+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday timeZone:(NSTimeZone*)timeZone;

+(void)logMemUsage;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (void)showFBAuthError:(NSError*)error;
+ (UIImage*)imageNamed:(NSString*)name;

@end
