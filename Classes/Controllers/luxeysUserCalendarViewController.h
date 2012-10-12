//
//  luxeysUserCalendarViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/05.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysCellPicCalendar.h"
#import "luxeysHeaderCalendar.h"
#import "luxeysButtonBrown30.h"
#import "MBProgressHUD.h"

@interface luxeysUserCalendarViewController : UICollectionViewController {
    NSInteger userID;
    NSMutableArray *pics;
    NSDate *date;
}

- (void)setUserID:(NSInteger)aUserID;

@end
