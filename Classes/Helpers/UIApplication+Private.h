//
//  UIApplication+Private.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/7/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Private)

- (void)setSystemVolumeHUDEnabled:(BOOL)enabled forAudioCategory:(NSString *)category;
- (void)setSystemVolumeHUDEnabled:(BOOL)enabled;

@end
