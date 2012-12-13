//
//  luxeysPicInfoViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXCellDataField.h"
#import "LatteAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "LXAppDelegate.h"
#import "LXPicDetailViewController.h"
#import "Picture.h"

@interface LXPicInfoViewController : UITableViewController {
    NSDictionary *exif;
    NSDictionary *picDict;
    NSArray *keyBasic;
    NSArray *keyExif;
    NSMutableArray *sections;
    Picture *pic;
    int picID;
}

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imagePic;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;

- (IBAction)touchBack:(id)sender;
- (void)setPictureID:(int)aPicID;
@end
