//
//  luxeysPicInfoViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysCellProfile.h"
#import "luxeysLatteAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysAppDelegate.h"
#import "LuxeysPicture.h"

@interface luxeysPicInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSDictionary *exif;
    NSDictionary *picDict;
    NSArray *keyBasic;
    NSArray *keyExif;
    NSMutableArray *sections;
    LuxeysPicture *pic;
    int picID;
}

@property (strong, nonatomic) IBOutlet UITableView *tableInfo;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imagePic;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;

- (IBAction)touchBack:(id)sender;
- (void)setPictureID:(int)aPicID;
@end
