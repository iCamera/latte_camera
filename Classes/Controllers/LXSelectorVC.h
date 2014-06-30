//
//  LXSelectorVC.h
//  Latte camera
//
//  Created by Serkan Unal on 6/20/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXSelectorVC : UIViewController
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) NSDictionary *data;
- (IBAction)touchChange:(id)sender;
-(void)initData:(NSDictionary *)_data;
@end
