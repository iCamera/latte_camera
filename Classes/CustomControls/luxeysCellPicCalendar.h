//
//  luxeysCellPicCalendar.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/05.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface luxeysCellPicCalendar : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UILabel *labelBigDate;
@property (strong, nonatomic) IBOutlet UIButton *buttonPic;
@property (strong, nonatomic) IBOutlet UIImageView *imageLabel;

@end
