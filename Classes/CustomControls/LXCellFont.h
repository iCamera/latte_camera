//
//  LXCellFont.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/17/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXCellFont : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelSample;
@property (strong, nonatomic) IBOutlet UILabel *labelFontName;
@property (strong, nonatomic) IBOutlet UIView *viewSelectIndicator;
@property (strong, nonatomic) NSDictionary *fontInfo;
@property (strong, nonatomic) IBOutlet UIImageView *imageDownloaded;

@end
