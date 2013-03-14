//
//  LXUserNavButton.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXUserNavButton : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *buttonNotify;
@property (strong, nonatomic) IBOutlet UIButton *buttonSetting;
@property (strong, nonatomic) IBOutlet UILabel *labelCount;

@property (assign, nonatomic) NSInteger notifyCount;

@end
