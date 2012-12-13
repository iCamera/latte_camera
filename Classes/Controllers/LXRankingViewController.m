//
//  luxeysRankingViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/4/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXRankingViewController.h"
#import "LXAppDelegate.h"

@interface LXRankingViewController ()

@end

@implementation LXRankingViewController
@synthesize buttonDaily;
@synthesize buttonWeekly;
@synthesize buttonMonthly;
@synthesize viewTab;
@synthesize loadIndicator;
@synthesize buttonNavLeft;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveLoggedIn:)
                                                     name:@"LoggedIn"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveLoggedOut:)
                                                     name:@"LoggedOut"
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];

    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tableView addSubview:refreshHeaderView];
        
    loadEnded = FALSE;
    ranktype = @"daily";
    rankpage = 1;
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;

    navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.revealController action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    if (app.currentUser)
        navigationBarPanGestureRecognizer.enabled = true;
    else
        navigationBarPanGestureRecognizer.enabled = false;
    [buttonNavLeft addTarget:app.revealController action:@selector(revealLeft:) forControlEvents:UIControlEventTouchUpInside];

    [self loadRanking];
    
    if (app.currentUser != nil) {
        [self receiveLoggedIn:nil];
    }

}

- (void)viewDidUnload
{
    [self setButtonDaily:nil];
    [self setButtonWeekly:nil];
    [self setButtonMonthly:nil];
    [self setViewTab:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)loadRanking {
    NSString* url = [NSString stringWithFormat:@"picture/ranking/%@/%d", ranktype, rankpage];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    
    [[LatteAPIClient sharedClient] getPath:url
                                      parameters: nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             pics = [Picture mutableArrayFromDictionary:JSON withKey:@"pics"];
                                             [self.tableView reloadData];

                                             [self doneLoadingTableViewData];
                                             [HUD hide:YES];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             TFLog(@"Something went wrong (Ranking)");
                                             [self doneLoadingTableViewData];
                                             [HUD hide:YES];
                                         }
     ];
}

- (void)loadMore {
    rankpage += 1;
    NSString* url = [NSString stringWithFormat:@"picture/ranking/%@/%d", ranktype, rankpage];
    
    [loadIndicator startAnimating];
    [self.tableView beginUpdates];
    [[LatteAPIClient sharedClient] getPath:url
                                parameters:nil
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       int rowCountPrev = [self.tableView numberOfRowsInSection:0];
                                       NSArray *newPics = [JSON objectForKey:@"pics"];
                                       for (NSDictionary *pic in newPics) {
                                           [pics addObject:[Picture instanceFromDictionary:pic]];
                                       }
                                       
                                       if (newPics.count == 0)
                                           loadEnded = true;
                                       else {
                                           int newRows = [self tableView:self.tableView numberOfRowsInSection:0] - rowCountPrev;
                                           NSMutableArray *paths = [[NSMutableArray alloc] init];
                                           for (int i = 0; i < newRows ; i++) {
                                               [paths addObject:[NSIndexPath indexPathForRow:i+rowCountPrev inSection:0]];
                                           }
                                           [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
                                       }
                                       
                                       [self.tableView endUpdates];
                                       [loadIndicator stopAnimating];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Ranking)");
                                       [loadIndicator stopAnimating];
                                       [self.tableView endUpdates];
                                   }
     ];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)touchTab:(UIButton*)sender {
    loadEnded = false;
    
    switch (sender.tag) {
        case 1:{
            buttonDaily.enabled = FALSE;
            buttonWeekly.enabled = TRUE;
            buttonMonthly.enabled = TRUE;
            ranktype = @"daily";
            rankpage = 1;
            [self loadRanking];
        }
        break;
        case 2: {
            buttonDaily.enabled = TRUE;
            buttonWeekly.enabled = FALSE;
            buttonMonthly.enabled = TRUE;
            ranktype = @"weekly";
            rankpage = 1;
            [self loadRanking];
        }
        break;
        case 3: {
            buttonDaily.enabled = TRUE;
            buttonWeekly.enabled = TRUE;
            buttonMonthly.enabled = FALSE;
            ranktype = @"monthly";
            rankpage = 1;
            [self loadRanking];
        }
        break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = pics.count;
    if (count > 1) {
        NSInteger ret = (count - 1) / 3 + ((count-1)%3>0?1:0);
        return ret;
    }
    else if (count == 1)
        return 1;
    else
        return 0;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)initButton:(UIButton*)button {
    button.layer.borderColor = [[UIColor whiteColor] CGColor];
    button.layer.borderWidth = 3;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:button.bounds];
    button.layer.masksToBounds = NO;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    button.layer.shadowOpacity = 0.5f;
    button.layer.shadowRadius = 1.5f;
    button.layer.shadowPath = shadowPathPic.CGPath;
    
    [button addTarget:self action:@selector(didSelectPic:) forControlEvents:UIControlEventTouchUpInside];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LXCellRankLv1 *cellLv1 = [tableView dequeueReusableCellWithIdentifier:@"First"];
        if (nil == cellLv1) {
            cellLv1 = [[LXCellRankLv1 alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"First"];
        }
        Picture *pic = [pics objectAtIndex:0];

        CGRect frame = cellLv1.buttonPic1.frame;
        frame.size.height = [LXUtils heightFromWidth:308
                                                      width:[pic.width floatValue]
                                                     height:[pic.height floatValue]];
        cellLv1.buttonPic1.frame = frame;
        [self initButton:cellLv1.buttonPic1];
        
        [cellLv1.buttonPic1 loadBackground:pic.urlMedium];
        cellLv1.buttonPic1.tag = [pic.pictureId integerValue];
        
        return cellLv1;
    } else {
        LXCellRankLv2 *cellLv2 = [tableView dequeueReusableCellWithIdentifier:@"Second"];
        if (nil == cellLv2) {
            cellLv2 = [[LXCellRankLv2 alloc] initWithStyle:UITableViewCellStyleDefault
                                                                     reuseIdentifier:@"Second"];
            TFLog(@"New row");
        }
        
        [self initButton:cellLv2.buttonPic2];
        [self initButton:cellLv2.buttonPic3];
        [self initButton:cellLv2.buttonPic4];

        NSInteger baseIdx = (indexPath.row-1)*3+1;
        
        if (pics.count >= baseIdx + 2) {
            Picture *pic = [pics objectAtIndex:baseIdx];
            [cellLv2.buttonPic2 loadBackground:pic.urlSquare];
            cellLv2.buttonPic2.tag = [pic.pictureId integerValue];
            cellLv2.label1st.text = [NSString stringWithFormat:@"%d", baseIdx+1];
            if (baseIdx == 1)
                [cellLv2.imageBg1 setImage:[UIImage imageNamed:@"bg_rank2.png"]];
            else
                [cellLv2.imageBg1 setImage:[UIImage imageNamed:@"bg_rank3-9.png"]];
        }
        
        if (pics.count > baseIdx  + 3) {
            Picture *pic = [pics objectAtIndex:baseIdx + 1];
            [cellLv2.buttonPic3 loadBackground:pic.urlSquare];
            cellLv2.buttonPic3.tag = [pic.pictureId integerValue];
            cellLv2.label2nd.text = [NSString stringWithFormat:@"%d", baseIdx+2];
            if (baseIdx == 2)
                [cellLv2.imageBg2 setImage:[UIImage imageNamed:@"bg_rank3.png"]];
            else
                [cellLv2.imageBg2 setImage:[UIImage imageNamed:@"bg_rank3-9.png"]];
        }
        
        if (pics.count > baseIdx  + 4) {
            Picture *pic = [pics objectAtIndex:baseIdx + 2];
            [cellLv2.buttonPic4 loadBackground:pic.urlSquare];
            cellLv2.buttonPic4.tag = [pic.pictureId integerValue];
            cellLv2.label3rd.text = [NSString stringWithFormat:@"%d", baseIdx+3];
        }
        
        return cellLv2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        Picture *pic = [pics objectAtIndex:0];
        
        float newheight = [LXUtils heightFromWidth:308
                                                      width:[pic.width floatValue]
                                                     height:[pic.height floatValue]];
        return newheight + 6;
    }
    else 
        return 105;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    //Load more
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
            [self loadMore];
        }
    }
}

- (void)didSelectPic:(UIButton*)buttonImage {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXPicDetailViewController *viewPicDetail = [mainStoryboard instantiateViewControllerWithIdentifier:@"PictureDetail"];
    viewPicDetail.pic = [[pics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pictureId == %d", buttonImage.tag]]] lastObject];
    [self.navigationController pushViewController:viewPicDetail animated:YES];
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    navigationBarPanGestureRecognizer.enabled = true;
    buttonNavLeft.hidden = false;
}

- (void)receiveLoggedOut:(NSNotification *) notification {
    navigationBarPanGestureRecognizer.enabled = false;

    buttonNavLeft.hidden = true;
}

- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    rankpage = 1;
    [self loadRanking];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


@end
