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
}

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imagePic;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;

@property (assign, nonatomic) NSUInteger pictureID;

- (IBAction)touchBack:(id)sender;
@end
