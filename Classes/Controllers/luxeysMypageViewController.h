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
@property (strong, nonatomic) IBOutlet UIScrollView *viewScroll;
- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)touchSetting:(id)sender;

@property (strong, nonatomic) NSArray *arPhoto;
@property (strong, nonatomic) NSArray *arFriend;
@property (strong, nonatomic) NSMutableArray *arFeed;
@property (nonatomic, retain, readonly) SSCollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITableView *tableTimeline;
@property (strong, nonatomic) IBOutlet UITableView *tableFriend;
@property (strong, nonatomic) IBOutlet UIButton *buttonVoteCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonPicCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonFriendCount;
- (IBAction)touchVoteCount:(id)sender;
- (IBAction)touchPicCount:(id)sender;
- (IBAction)touchFriendCount:(id)sender;


@end
