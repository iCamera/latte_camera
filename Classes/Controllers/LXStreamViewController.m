//
//  LXStreamViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXStreamViewController.h"
#import "LXStreamBrickCell.h"
#import "Feed.h"
#import "Picture.h"
#import "LatteAPIClient.h"
#import "LXMyPageViewController.h"


@interface LXStreamViewController ()

@end

@implementation LXStreamViewController {
    NSMutableArray *feeds;
    BOOL loadEnded;
    BOOL loading;
    NSString *area;
    UIRefreshControl *refresh;
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
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout*)self.collectionView.collectionViewLayout;
    layout.minimumColumnSpacing = 4;
    layout.minimumInteritemSpacing = 4;
    layout.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6);
    
    refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refresh];
//    self.collectionView.alwaysBounceVertical = YES;
    loadEnded = false;
    loading = false;
     
    [self loadMore:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)becomeActive:(id)sender {
    [self reloadView];
}


- (void)reloadView {
    [self loadMore:YES];
}

- (void)loadMore:(BOOL)reset {
    if (loading || loadEnded) {
        return;
    }
    
    Feed *feed = feeds.lastObject;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    area = @"local";
    [param setObject:area forKey:@"area"];
    
    if (!reset) {
        if (feed) {
            [param setObject:feed.feedID forKey:@"last_id"];
        }
    }
    
    loading = true;
    [refresh beginRefreshing];
    [[LatteAPIClient sharedClient] GET:@"user/everyone/timeline" parameters: param success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        if (reset) {
            feeds = [Feed mutableArrayFromDictionary:JSON withKey:@"feeds"];
            loadEnded = false;
            [self.collectionView reloadData];
        } else {
            NSMutableArray *newFeeds = [Feed mutableArrayFromDictionary:JSON withKey:@"feeds"];
            
            if (newFeeds.count > 0) {
                NSMutableArray *indexes = [[NSMutableArray alloc] init];
                for (NSInteger i = feeds.count; i < feeds.count + newFeeds.count; i++) {
                    NSIndexPath *index = [NSIndexPath indexPathForItem:i inSection:0];
                    [indexes addObject:index];
                }
                
                [feeds addObjectsFromArray:newFeeds];
                [self.collectionView insertItemsAtIndexPaths:indexes];
            } else {
                loadEnded = true;
            }
        }
        loading = false;
        [refresh endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        loading = false;
        [refresh endRefreshing];
        DLog(@"Something went wrong (Welcome)");
    }];
}

- (NSMutableArray*)flatPictureArray {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (Feed *feed in feeds) {
        for (Picture *picture in feed.targets) {
            [ret addObject:picture];
        }
    }
    return ret;
}


- (NSDictionary *)pictureAfterPicture:(Picture *)picture {
    Feed *feed = [LXUtils feedFromPicID:[picture.pictureId longValue] of:feeds];
    NSUInteger current = [feeds indexOfObject:feed];
    if (current == NSNotFound || current == feeds.count-1) {
        return nil;
    }
    Feed *feedNext = feeds[current+1];
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         feedNext.targets[0], @"picture",
                         feedNext.user, @"user",
                         nil];
    
    // Loadmore
    if (current > feeds.count - 6)
        [self loadMore:NO];
    return ret;
    
    return nil;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {
    Feed *feed = [LXUtils feedFromPicID:[picture.pictureId longValue] of:feeds];
    NSUInteger current = [feeds indexOfObject:feed];
    if (current == NSNotFound || current == 0) {
        return nil;
    }
    Feed *feedPrev = feeds[current-1];
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         feedPrev.targets[0], @"picture",
                         feedPrev.user, @"user",
                         nil];
    return ret;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Feed *feed = feeds[indexPath.item];
    LXStreamBrickCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Brick" forIndexPath:indexPath];
    cell.picture = feed.targets[0];
    cell.buttonPicture.tag = indexPath.item;
    cell.delegate = self;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return feeds.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = feeds[indexPath.item];
    Picture *picture = feed.targets[0];
    NSInteger height = [LXUtils heightFromWidth:152 width:[picture.width floatValue] height:[picture.height floatValue]];
    return CGSizeMake(152, height);
}

- (void)showPic:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    
    Feed *feed = feeds[sender.tag];
    Picture *picture = feed.targets[0];
    viewGallery.user = feed.user;
    viewGallery.picture = picture;
    
    [self presentViewController:navGalerry animated:YES completion:nil];
}

- (void)showUser:(User *)user fromGallery:(LXGalleryViewController *)gallery {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    //    [refreshHeaderView egoRefreshScrollViewDidScroll:aScrollView];
    
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
