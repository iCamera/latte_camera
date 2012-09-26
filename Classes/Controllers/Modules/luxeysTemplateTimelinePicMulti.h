//
//  luxeysTemplateTimelinePicMulti.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/26.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface luxeysTemplateTimelinePicMulti : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUser;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollImage;

- (id)initWithPics:(NSArray *)_pics user:(NSDictionary *)_user section:(NSInteger)_section sender:(id)_sender;

@end
