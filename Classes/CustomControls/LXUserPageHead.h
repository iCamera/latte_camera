//
//  LXUserPageHead.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 7/29/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXUserPageHead : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonUsername;
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
- (IBAction)touchBack:(id)sender;

@end
