//
//  LXStreamViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXStreamViewController.h"
#import "LXStreamBrickCell.h"
#import "LXStreamFooter.h"
#import "Feed.h"
#import "Picture.h"
#import "LatteAPIClient.h"
#import "LXUserPageViewController.h"
#import "LXStreamHeader.h"
#import "LXNotificationBar.h"

#import "REFrostedViewController.h"
#import "MZFormSheetSegue.h"

@interface LXStreamViewController ()

@end

@implementation LXStreamViewController {
    NSMutableArray *feeds;
    BOOL loadEnded;
    UIRefreshControl *refresh;
    NSInteger currentTab;
    UICollectionViewLayout *layoutGrid;
    CHTCollectionViewWaterfallLayout *layoutWaterfall;
    NSString *browsingCountry;
    AFHTTPRequestOperation *currentRequest;
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
    
    feeds = [[NSMutableArray alloc] init];
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
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXCellBrick" bundle:nil] forCellWithReuseIdentifier:@"Brick"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXStreamHeader" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXStreamHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXStreamFooter" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXStreamFooter" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
    
    loadEnded = false;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    currentTab = [defaults integerForKey:@"LatteStreamView"];
    if (currentTab == 0) {
        [self.collectionView setCollectionViewLayout:layoutWaterfall animated:NO];
    } else {
        [self.collectionView setCollectionViewLayout:layoutGrid animated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:@"BecomeActive" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changedBrowsingCountry:)
                                                 name:@"ChangedBrowsingCountry" object:nil];
    
    browsingCountry = [defaults objectForKey:@"BrowsingCountry"];
    if (browsingCountry) {
        NSString *countryImage = [NSString stringWithFormat:@"%@.png", browsingCountry];
        [_buttonCountry setImage:[UIImage imageNamed:countryImage] forState:UIControlStateNormal];
    }
    refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(reloadView) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refresh];
    [self loadMore:YES];
    
    LXNotificationBar *viewNotification = [[LXNotificationBar alloc] initWithFrame:CGRectMake(0, 0, 70, 33)];
    viewNotification.parent = self;
    UIBarButtonItem *rightNav = [[UIBarButtonItem alloc] initWithCustomView:viewNotification];
    self.navigationItem.rightBarButtonItem = rightNav;
}

- (void)changedBrowsingCountry:(NSNotification*)notify {
    browsingCountry = notify.object;
    NSString *countryImage;
    if (browsingCountry && [browsingCountry isEqualToString:@"World"]) {
        countryImage = @"icon40-earth-color.png";
    } else {
        countryImage = [NSString stringWithFormat:@"%@.png", browsingCountry];
    }
    [_buttonCountry setImage:[UIImage imageNamed:countryImage] forState:UIControlStateNormal];
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
    [refresh beginRefreshing];
    [self loadMore:YES];
}

- (void)loadMore:(BOOL)reset {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];

    if (browsingCountry) {
        param[@"country"] = browsingCountry;
    }
 
    if (reset) {
        if (currentRequest.isExecuting) [currentRequest cancel];
        loadEnded = false;
    } else {
        if (currentRequest.isExecuting) return;
        Feed *feed = feeds.lastObject;
        if (feed) {
            [param setObject:feed.feedID forKey:@"last_id"];
        }
    }
    
    currentRequest = [[LatteAPIClient sharedClient] GET:@"user/everyone/timeline" parameters: param success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        
        NSMutableArray *newFeeds = [Feed mutableArrayFromDictionary:JSON withKey:@"feeds"];

        loadEnded = newFeeds.count == 0;
        if (reset) {
            feeds = newFeeds;
            layoutWaterfall.footerHeight = loadEnded?320:50;
            [self.collectionView reloadData];
        } else {
            if (newFeeds.count > 0) {
                NSMutableArray *indexes = [[NSMutableArray alloc] init];
                for (NSInteger i = feeds.count; i < feeds.count + newFeeds.count; i++) {
                    NSIndexPath *index = [NSIndexPath indexPathForItem:i inSection:0];
                    [indexes addObject:index];
                }
                
                [feeds addObjectsFromArray:newFeeds];
                [self.collectionView insertItemsAtIndexPaths:indexes];
            }
        }
        
        [refresh endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

#pragma mark - Gallery datasource


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


#pragma mark - Collection Datasource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        LXStreamHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"Header"
                                                                 forIndexPath:indexPath];
        [header.buttonWaterfall addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventTouchUpInside];
        [header.buttonGrid addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventTouchUpInside];
        return header;
    }
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        LXStreamHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                    withReuseIdentifier:@"Header"
                                                                           forIndexPath:indexPath];
        [header.buttonWaterfall addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventTouchUpInside];
        [header.buttonGrid addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventTouchUpInside];
        header.buttonWaterfall.selected = NO;
        header.buttonGrid.selected = YES;
        return header;
    }
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionFooter] || [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        LXStreamFooter *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:@"Footer"
                                                                               forIndexPath:indexPath];
        if (loadEnded) {
            [footerView.indicatorLoading stopAnimating];
            footerView.imageEmpty.hidden = feeds.count > 0;
        } else {
            [footerView.indicatorLoading startAnimating];
            footerView.imageEmpty.hidden = YES;
        }
        return footerView;
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LXStreamBrickCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Brick" forIndexPath:indexPath];
    Feed *feed = feeds[indexPath.item];
    cell.picture = feed.targets[0];
    cell.user = feed.user;
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
    if (loadEnded && feeds.count == 0) {
        layoutWaterfall.footerHeight = 320;
        return CGSizeMake(320, 320);
    } else {
        layoutWaterfall.footerHeight = 50;
        return CGSizeMake(320, 50);
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Country"]) {
        MZFormSheetSegue *sheet = (MZFormSheetSegue*)segue;
        sheet.formSheetController.cornerRadius = 0;
        sheet.formSheetController.shouldDismissOnBackgroundViewTap = YES;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)switchTab:(UIButton *)sender {
    currentTab = sender.tag;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:currentTab forKey:@"LatteStreamView"];
    [defaults synchronize];
    
    if (currentTab == 0) {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self.collectionView setCollectionViewLayout:layoutWaterfall animated:YES];
    } else {
        [self.collectionView setCollectionViewLayout:layoutGrid animated:YES];
    }
}

- (IBAction)showMenu:(id)sender;
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)touchCountry:(id)sender {
    if (self.collectionView.contentOffset.y == 0) {
        [self performSegueWithIdentifier:@"Country" sender:self];
    }
}


@end
