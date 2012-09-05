//
//  luxeysMypageViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCollectionView.h"
#import "luxeysButtonBrown30.h"

@interface luxeysMypageViewController : UIViewController <SSCollectionViewDataSource, SSCollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageProfilePic;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonNavRight;
@property (strong, nonatomic) IBOutlet UIButton *buttonPhoto;
@property (strong, nonatomic) IBOutlet UIButton *buttonCalendar;
- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)touchSetting:(id)sender;

@property (strong, nonatomic) NSArray *arPhoto;
@property (strong, nonatomic) NSMutableArray *arFeed;
@property (nonatomic, retain, readonly) SSCollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITableView *tableTimeline;
@property (strong, nonatomic) IBOutlet UILabel *labelPicNum;
@property (strong, nonatomic) IBOutlet UILabel *labelVote;
@property (strong, nonatomic) IBOutlet UILabel *labelFriend;

@end
