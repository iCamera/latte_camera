//
//  luxeysRankingViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/4/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysRankingViewController.h"

@interface luxeysRankingViewController ()

@end

@implementation luxeysRankingViewController
@synthesize buttonDaily;
@synthesize buttonWeekly;
@synthesize buttonMonthly;
@synthesize viewTab;
@synthesize loadIndicator;

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
    self.viewTab.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];

    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tableView addSubview:refreshHeaderView];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 70, 320, 10);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor clearColor] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2f] CGColor],
                       nil];
    [viewTab.layer insertSublayer:gradient atIndex:0];
    
    loadEnded = FALSE;
    ranktype = @"daily";
    rankpage = 1;
    
    [self loadRanking];
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
    NSString* url = [NSString stringWithFormat:@"api/picture/ranking/%@/%d", ranktype, rankpage];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    [[LatteAPIClient sharedClient] getPath:url
                                      parameters: nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             pics = [Picture mutableArrayFromDictionary:JSON withKey:@"pics"];
                                             [self.tableView reloadData];

                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             
                                             [self doneLoadingTableViewData];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Ranking)");
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             
                                             [self doneLoadingTableViewData];
                                         }
     ];
    });
}

- (void)loadMore {
    rankpage += 1;
    NSString* url = [NSString stringWithFormat:@"api/picture/ranking/%@/%d", ranktype, rankpage];
    
    [loadIndicator startAnimating];
    [self.tableView beginUpdates];
    [[LatteAPIClient sharedClient] getPath:url
                                      parameters: nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             int rowCountPrev = [self.tableView numberOfRowsInSection:0];
                                             NSArray *newPics = [JSON objectForKey:@"pics"];
                                             for (NSDictionary *pic in newPics) {
                                                 [pics addObject:[Picture instanceFromDictionary:pic]];
                                             }
                                             
                                             if (newPics.count == 0)
                                                 loadEnded = true;
                                             else {
                                                 int newRows = newPics.count / 4 + (newPics.count%4>0?1:0);
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
                                             NSLog(@"Something went wrong (Ranking)");
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
    if (count > 4) {
        NSInteger ret = (count - 4) / 4 + 2 + ((count-4)%4>0?1:0);
        return ret;
    }
    else if (count > 1)
        return 2;
    else if (count == 1)
        return 1;
    else
        return 0;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)initButton:(UIButton*)button index:(NSInteger)index {
    Picture *pic = [pics objectAtIndex:index];
    if (index == 0)
        [button loadBackground:pic.urlMedium];
    else
        [button loadBackground:pic.urlSquare];


    button.layer.borderColor = [[UIColor whiteColor] CGColor];
    button.layer.borderWidth = 3;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:button.bounds];
    button.layer.masksToBounds = NO;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    button.layer.shadowOpacity = 0.5f;
    button.layer.shadowRadius = 1.5f;
    button.layer.shadowPath = shadowPathPic.CGPath;
    
    button.tag = [pic.pictureId integerValue];
    
    [button addTarget:self action:@selector(didSelectPic:) forControlEvents:UIControlEventTouchUpInside];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        luxeysCellRankLv1 *cellLv1 = [tableView dequeueReusableCellWithIdentifier:@"First"];
        if (nil == cellLv1) {
            cellLv1 = [[luxeysCellRankLv1 alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"First"];
        }
        CGRect frame = cellLv1.buttonPic1.frame;
        frame.size.height = [self tableView:self.tableView heightForRowAtIndexPath:indexPath] - 10;
        cellLv1.buttonPic1.frame = frame;
        [self initButton:cellLv1.buttonPic1 index:0];
        return cellLv1;
    } else if (indexPath.row == 1) {
        luxeysCellRankLv2 *cellLv2 = [tableView dequeueReusableCellWithIdentifier:@"Second"];
        if (nil == cellLv2) {
            cellLv2 = [[luxeysCellRankLv2 alloc] initWithStyle:UITableViewCellStyleDefault
                                                                     reuseIdentifier:@"Second"];
        }
            
            [self initButton:cellLv2.buttonPic2 index:1];
            
            
            if (pics.count > 2) {
                [self initButton:cellLv2.buttonPic3 index:2];
            }
            
            if (pics.count > 3) {
                [self initButton:cellLv2.buttonPic4 index:3];
            }
        
        return cellLv2;
    } else {
        luxeysCellRankLv3 *cellLv3 = [tableView dequeueReusableCellWithIdentifier:@"Third"];
        if (nil == cellLv3) {
            cellLv3 = [[luxeysCellRankLv3 alloc] initWithStyle:UITableViewCellStyleDefault
                                                                     reuseIdentifier:@"Third"];
        }
        
        
        [self initButton:cellLv3.buttonPic1 index:(indexPath.row-2)*4+4];
        
        if (pics.count > (indexPath.row-2)*4+5) {
            [self initButton:cellLv3.buttonPic2 index:(indexPath.row-2)*4+5];
        }
        
        if (pics.count > (indexPath.row-2)*4+6) {
            [self initButton:cellLv3.buttonPic3 index:(indexPath.row-2)*4+6];
        }
        
        
        if (pics.count > (indexPath.row-2)*4+7) {
            [self initButton:cellLv3.buttonPic4 index:(indexPath.row-2)*4+7];
        }
        
        /*if (indexPath.row == 2) {
            cellLv3.badgeRank8.hidden = pics.count < 8;
            cellLv3.badgeRank7.hidden = pics.count < 7;
            cellLv3.badgeRank6.hidden = pics.count < 6;
            cellLv3.badgeRank5.hidden = pics.count < 5;
        }*/
        
        return cellLv3;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        Picture *pic = [pics objectAtIndex:0];
        
        float newheight = [luxeysUtils heightFromWidth:300
                                                      width:[pic.width floatValue]
                                                     height:[pic.height floatValue]];
        return newheight + 10;
    }
    else if (indexPath.row == 1)
        return 105;
    else
        return 80;
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
    [self performSegueWithIdentifier:@"PictureDetail" sender:buttonImage];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        [viewPicDetail setPictureID:sender.tag];
    }
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
