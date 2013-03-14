//
//  LXVoteViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXVoteViewController.h"
#import "LXAppDelegate.h"
#import "LXCollectionCellUser.h"
#import "LXMyPageViewController.h"

@interface LXVoteViewController () {
    NSMutableArray *voters;
    NSInteger guestVoteCount;
}

@end

@implementation LXVoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPicture:(Picture *)picture {
    if (picture.isOwner && ([picture.voteCount integerValue] > 0)) {

        NSString *url = [NSString stringWithFormat:@"picture/%d/votes", [picture.pictureId integerValue]];
        LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [[LatteAPIClient sharedClient] getPath:url
                                    parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           NSMutableArray *votes = [User mutableArrayFromDictionary:JSON withKey:@"votes"];
                                           
                                           guestVoteCount = [picture.voteCount integerValue] - votes.count;
                                           NSInteger userVoteCount = 0;
                                           voters = [[NSMutableArray alloc] init];
                                           for (User *voteUser in votes) {
                                               if ([voteUser.userId integerValue] != 0) {
                                                   [voters addObject:voteUser];
                                                   userVoteCount++;
                                               } else
                                                   guestVoteCount++;
                                           }
                                           
                                           
                                           if (guestVoteCount > 0) {
                                               UILabel *labelGuestVote = [[UILabel alloc] initWithFrame:CGRectMake(userVoteCount*45+5, 0, 40, 40)];
                                               labelGuestVote.backgroundColor = [UIColor clearColor];
                                               labelGuestVote.textColor = [UIColor colorWithRed:187.0/255.0 green:184.0/255.0 blue:169.0/255.0 alpha:1];
                                               labelGuestVote.textAlignment = NSTextAlignmentCenter;
                                               labelGuestVote.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
                                               labelGuestVote.text = [NSString stringWithFormat:@"+%d", guestVoteCount];
                                           } else {

                                           }
                                           
                                           [self.collectionView reloadData];
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           TFLog(@"Something went wrong (Get vote)");
                                           
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                           message:error.localizedDescription
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                 otherButtonTitles:nil];
                                           [alert show];
                                       }];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LXCollectionCellUser *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"User" forIndexPath:indexPath];
    cell.user = voters[indexPath.item];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return voters.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUser.user = voters[indexPath.item];

    [self.navigationController pushViewController:viewUser animated:YES];
}

@end
