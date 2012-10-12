//
//  luxeysImageUtils.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysUtils.h"

@implementation luxeysUtils

+ (float)heightFromWidth:(float)newwidth width:(float)width height:(float)height {
    return newwidth*height/width;
}

+ (NSString *)timeDeltaFromNow:(NSDate*)aDate {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    [dateFormatter setDoesRelativeDateFormatting:YES];
    return [dateFormatter stringFromDate:aDate];
}

+ (NSDate *)dateFromJSON:(NSString *)aDate {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [dateFormatter dateFromString:aDate];
}

@end
