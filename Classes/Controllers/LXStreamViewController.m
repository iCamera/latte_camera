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
#import "LXUserPageViewController.h"
#import "LXStreamHeader.h"

#import "REFrostedViewController.h"

@interface LXStreamViewController ()

@end

@implementation LXStreamViewController {
    NSMutableArray *feeds;
    BOOL loadEnded;
    BOOL loading;
    NSString *area;
    UIRefreshControl *refresh;
    NSInteger currentTab;
    UICollectionViewLayout *layoutGrid;
    CHTCollectionViewWaterfallLayout *layoutWaterfall;
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
    layoutGrid = self.collectionView.collectionViewLayout;
    layoutWaterfall = [[CHTCollectionViewWaterfallLayout alloc] init];
    layoutWaterfall.minimumColumnSpacing = 4;
    layoutWaterfall.minimumInteritemSpacing = 4;
    layoutWaterfall.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6);
    layoutWaterfall.headerHeight = 44;
    layoutWaterfall.footerHeight = 50;
    
//    UICollectionViewFlowLayout
    [self.collectionView setCollectionViewLayout:layoutWaterfall animated:NO];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXStreamHeader" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXStreamHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXStreamFooter" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXStreamFooter" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
    
    loadEnded = false;
    loading = false;
    currentTab = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:@"BecomeActive" object:nil];
    
    [self loadMore:YES];
}

- (void)becomeActive:(id)sender {
    [self reloadView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        LXStreamHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"Header"
                                                                 forIndexPath:indexPath];
        [header.segmentView addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventValueChanged];
        [header.buttonRefresh addTarget:self action:@selector(reloadView) forControlEvents:UIControlEventValueChanged];
        return header;
    }
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        LXStreamHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                    withReuseIdentifier:@"Header"
                                                                           forIndexPath:indexPath];
        [header.segmentView addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventValueChanged];
        [header.buttonRefresh addTarget:self action:@selector(reloadView) forControlEvents:UIControlEventValueChanged];
        header.segmentView.selectedSegmentIndex = 1;
        return header;
    }
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                    withReuseIdentifier:@"Footer"
                                                                           forIndexPath:indexPath];
    }
    
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                    withReuseIdentifier:@"Footer"
                                                                           forIndexPath:indexPath];
    }

    return nil;
}

- (void)switchTab:(UISegmentedControl *)sender {
    currentTab = sender.selectedSegmentIndex;
    if (currentTab == 0) {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self.collectionView setCollectionViewLayout:layoutWaterfall animated:YES];
    } else {
        [self.collectionView setCollectionViewLayout:layoutGrid animated:YES];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LXStreamBrickCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Brick" forIndexPath:indexPath];
    cell.feed = feeds[indexPath.item];
    cell.delegate = self;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return feeds.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(320, layoutWaterfall.headerHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(320, layoutWaterfall.footerHeight);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTab == 1) {
        return CGSizeMake(100, 100);
    } else {
        Feed *feed = feeds[indexPath.item];
        Picture *picture = feed.targets[0];
        NSInteger height = [LXUtils heightFromWidth:152 width:[picture.width floatValue] height:[picture.height floatValue]];
        return CGSizeMake(152, height);
    }
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

- (IBAction)showMenu
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)selectCountry:(id)sender {
    
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
