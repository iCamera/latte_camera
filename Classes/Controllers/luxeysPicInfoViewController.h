//
//  luxeysPicInfoViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysCellProfile.h"
#import "LatteAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysAppDelegate.h"
#import "Picture.h"

@interface luxeysPicInfoViewController : UITableViewController {
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
