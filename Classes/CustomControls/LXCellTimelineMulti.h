//
//  luxeysCellWelcomeMulti.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Feed.h"
#import "LXGalleryViewController.h"

@interface LXCellTimelineMulti : UITableViewCell {
    BOOL showControl;
}
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollPic;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelUserDate;

@property (strong, nonatomic) IBOutlet UIImageView *imageNationality;

@property (strong, nonatomic) Feed *feed;
@property (weak, nonatomic) UIViewController<LXGalleryViewControllerDataSource> *parent;
- (IBAction)showUser:(id)sender;

@end
