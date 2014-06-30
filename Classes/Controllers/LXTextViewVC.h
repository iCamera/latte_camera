//
//  LXTextViewVC.h
//  Latte camera
//
//  Created by Seri on 21-06-14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXTextViewVC : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UITextView *textViewContent;
- (IBAction)touchChange:(id)sender;
-(void)initData:(NSDictionary *)data;
@end
