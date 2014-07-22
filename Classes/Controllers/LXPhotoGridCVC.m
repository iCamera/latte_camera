//
//  LXPhotoGridCVC.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/16/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXPhotoGridCVC.h"
#import "LXUserPageViewController.h"
#import "LXStreamBrickCell.h"
#import "LatteAPIClient.h"
#import "LatteAPIv2Client.h"
#import "AFNetworking.h"
#import "LXStreamFooter.h"

@interface LXPhotoGridCVC ()

@end

@implementation LXPhotoGridCVC {
    NSMutableArray *pictures;
    NSInteger page;
    NSInteger limit;
    BOOL loadEnded;
    AFHTTPRequestOperation *currentRequest;
    UIActivityIndicatorView *indicatorLoading;
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
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXCellBrick" bundle:nil] forCellWithReuseIdentifier:@"Brick"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXStreamFooter" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
    
    limit = 30;
    // Do any additional setup after loading the view.
    [self loadMore:YES];
}

- (void)loadMore:(BOOL)reset {
    if (reset) {
        page = 1;
        if (currentRequest && currentRequest.isExecuting) {
            [currentRequest cancel];
        }
    } else {
        if (currentRequest && currentRequest.isExecuting) {
            return;
        }
    }

    if (_gridType == kPhotoGridUserLiked) {
        [self loadMoreUserLiked:reset];
    } else if (_gridType == kPhotoGridUserTag) {
        [self loadMoreUserTag:reset];
    }
}

- (void)loadMoreUserLiked:(BOOL)reset {
    [indicatorLoading startAnimating];
    currentRequest = [[LatteAPIClient sharedClient] GET:@"picture/user/me/voted"
                            parameters:@{@"limit": [NSNumber numberWithInteger:limit],
                                         @"page": [NSNumber numberWithInteger:page]}
                               success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                   
                                   NSMutableArray *data = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                   
                                   if (reset) {
                                       pictures = data;
                                   } else {
                                       [pictures addObjectsFromArray:data];
                                   }
                                   
                                   page += 1;
                                   loadEnded = data.count == 0;
                                   //[self.refreshControl endRefreshing];
                                   [self.collectionView reloadData];
                                   [indicatorLoading stopAnimating];
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   //[self.refreshControl endRefreshing];
                                   [indicatorLoading stopAnimating];
                               }];
}

- (void)loadMoreUserTag:(BOOL)reset {
    [indicatorLoading startAnimating];
    currentRequest = [[LatteAPIv2Client sharedClient] GET:@"picture"
                                             parameters:@{@"user_id": [NSNumber numberWithInteger:_userId],
                                                          @"tag": _keyword,
                                                          @"limit": [NSNumber numberWithInteger:limit],
                                                          @"page": [NSNumber numberWithInteger:page]}
                                                success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                    
                                                    NSMutableArray *data = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                                    
                                                    if (reset) {
                                                        pictures = data;
                                                    } else {
                                                        [pictures addObjectsFromArray:data];
                                                    }
                                                    
                                                    page += 1;
                                                    loadEnded = data.count == 0;
                                                    //[self.refreshControl endRefreshing];
                                                    [self.collectionView reloadData];
                                                    [indicatorLoading stopAnimating];
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    [indicatorLoading stopAnimating];
                                                    //[self.refreshControl endRefreshing];
                                                }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPic:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    
    viewGallery.picture = pictures[sender.tag];
    
    [self presentViewController:navGalerry animated:YES completion:nil];
}

- (NSDictionary *)pictureAfterPicture:(Picture *)picture {
    NSUInteger current = [pictures indexOfObject:picture];
    if (current == pictures.count-1) {
        return nil;
    }
    Picture *picNext = pictures[current+1];
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         picNext, @"picture",
                         nil];
    
    if (current > pictures.count - 6) {
        [self loadMore:NO];
    }
    
    return ret;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {
    NSUInteger current = [pictures indexOfObject:picture];
    if (current == 0) {
        return nil;
    }
    Picture *picPrev = pictures[current-1];
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         picPrev, @"picture",
                         nil];
    return ret;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        LXStreamFooter *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:@"Footer"
                                                                               forIndexPath:indexPath];
        indicatorLoading = footerView.indicatorLoading;
        
        if (loadEnded) {
            footerView.imageEmpty.hidden = pictures.count > 0;
        } else {
            footerView.imageEmpty.hidden = YES;
        }
        return footerView;
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LXStreamBrickCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Brick" forIndexPath:indexPath];
    Picture *picture = pictures[indexPath.item];
    cell.picture = picture;
    //cell.user = picture.user;
    
    // Hide
    cell.buttonUser.hidden = YES;
    cell.viewBg.hidden = YES;
    cell.labelUsername.hidden = YES;
    
    cell.delegate = self;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return pictures.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (loadEnded && pictures.count == 0) {
        return CGSizeMake(320, 320);
    } else {
        return CGSizeMake(320, 50);
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 100);
}



- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if (loadEnded)
        return;
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -100;
    if(y > h + reload_distance) {
        [self loadMore:NO];
    }
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
