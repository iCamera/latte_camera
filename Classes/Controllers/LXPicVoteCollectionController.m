//
//  LXPicVoteCollectionController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/30/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXPicVoteCollectionController.h"
#import "LatteAPIClient.h"
#import "LXCollectionCellUser.h"
#import "LXUserPageViewController.h"
#import "MZFormSheetController.h"
#import "LXCellLikeHeader.h"
#import "UIImageView+AFNetworking.h"

@interface LXPicVoteCollectionController ()

@end

@implementation LXPicVoteCollectionController {
    NSMutableArray *voters;
    NSInteger guestVoteCount;
}

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
    _picture = picture;
    if (picture.isOwner && ([picture.voteCount integerValue] > 0)) {
        
        NSString *url = [NSString stringWithFormat:@"picture/%ld/votes", [picture.pictureId longValue]];
        
        [[LatteAPIClient sharedClient] GET:url
                                parameters: nil
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
                                       
                                       [self.collectionView reloadData];
                                   } failure:nil];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= voters.count) {
        LXCollectionCellUser *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"User" forIndexPath:indexPath];
        return cell;
    } else {
        LXCollectionCellUser *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"User" forIndexPath:indexPath];
        cell.user = voters[indexPath.item];
        return cell;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return voters.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUser.user = voters[indexPath.item];
    
    if (_isModal) {
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            [_parent.navigationController pushViewController:viewUser animated:YES];
        }];
    } else {
        [self.navigationController pushViewController:viewUser animated:YES];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && !_isModal) {
        LXCellLikeHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                      withReuseIdentifier:@"Header"
                                                                             forIndexPath:indexPath];
        [header.imageHeader setImageWithURL:[NSURL URLWithString:_picture.urlMedium]];
        return header;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (!_isModal) {
        return CGSizeMake(320, 100);
    }
    return CGSizeZero;
}



- (BOOL)prefersStatusBarHidden {
    return _isModal;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
