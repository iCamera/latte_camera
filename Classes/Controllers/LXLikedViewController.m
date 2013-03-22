//
//  luxeysFav2ViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXLikedViewController.h"
#import "LatteAPIClient.h"
#import "LXAppDelegate.h"
#import "Picture.h"
#import "UIButton+AsyncImage.h"
#import "LXCellGrid.h"
#import "LXButtonBack.h"

@interface LXLikedViewController ()

@end

@implementation LXLikedViewController {
    NSMutableArray *pictures;
    BOOL reloading;
    EGORefreshTableHeaderView *refreshHeaderView;
    NSInteger page;
    BOOL loadEnded;
}

@synthesize loadIndicator;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Liked Screen"];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    // Do any additional setup after loading the view.
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tableView addSubview:refreshHeaderView];
    
    //setup back button
    UIBarButtonItem *navLeftItem = self.navigationItem.leftBarButtonItem;
    LXButtonBack *buttonBack = (LXButtonBack*)navLeftItem.customView;
    [buttonBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    
    [self reloadFav];

}


- (void)reloadFav {
    page = 0;
    loadEnded = false;
    [self loadFav];
}

- (void)loadFav {
    [loadIndicator startAnimating];
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    page += 1;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token",
                            [NSNumber numberWithInt:page], @"page",
                            [NSNumber numberWithInt:30], @"limit",
                            nil];
    
    [[LatteAPIClient sharedClient] getPath:@"picture/user/me/voted"
                                parameters: params
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       NSMutableArray *newData = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                       
                                       if (newData.count == 0) {
                                           loadEnded = true;
                                       }
                                       
                                       if (page == 1) {
                                           pictures = newData;
                                           [self.tableView reloadData];
                                       } else {
                                           [self.tableView beginUpdates];
                                           int rowCountPrev = [self.tableView numberOfRowsInSection:0];
                                           
                                           [pictures addObjectsFromArray:newData];
                                           
                                           if (newData.count > 0) {
                                               int newRows = [self tableView:self.tableView numberOfRowsInSection:0] - rowCountPrev;
                                               NSMutableArray *paths = [[NSMutableArray alloc] init];
                                               for (int i = 0; i < newRows ; i++) {
                                                   [paths addObject:[NSIndexPath indexPathForRow:i+rowCountPrev inSection:0]];
                                               }
                                               [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
                                           }
                                           
                                           [self.tableView endUpdates];
                                       }
                                       
                                       [self doneLoadingTableViewData];
                                       [loadIndicator stopAnimating];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Fav)");
                                       
                                       [self doneLoadingTableViewData];
                                       [loadIndicator stopAnimating];
                                   }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return pictures.count / 3 + (pictures.count%3>0?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:@"Grid" forIndexPath:indexPath];

    [cell setPictures:pictures forRow:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}

- (void)showPic:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    viewGallery.user = app.currentUser;
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
#pragma mark - Table view delegate

- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    
    [self reloadFav];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
        
    if (loadEnded)
        return;

    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -100;
    if(y > h + reload_distance) {
        if (!loadIndicator.isAnimating) {
            [self loadFav];
        }
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)viewDidUnload {
    [self setLoadIndicator:nil];
    [super viewDidUnload];
}
@end
