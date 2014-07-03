//
//  luxeysCellNotify.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Picture.h"
#import "LXGalleryViewController.h"

@interface LXCellNotify : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *buttonImage;
@property (strong, nonatomic) IBOutlet UILabel *labelNotify;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;

@property (strong, nonatomic) NSDictionary *notify;

@property (weak, nonatomic) UIViewController<LXGalleryViewControllerDataSource> *parent;

- (IBAction)touchImage:(id)sender;

@end
