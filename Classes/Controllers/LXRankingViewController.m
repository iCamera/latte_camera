//
//  luxeysRankingViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/4/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXRankingViewController.h"
#import "LXAppDelegate.h"
#import "LXCellGrid.h"

typedef enum {
    kLayoutNormal,
    kLayoutCalendar,
} RankingPage;

@interface LXRankingViewController ()

@end

@implementation LXRankingViewController {
    BOOL loadEnded;
    NSString* ranktype;
    NSInteger rankpage;
    NSMutableArray *pics;
    NSMutableArray *days;
    NSInteger rankLayout;
    BOOL reloading;
    EGORefreshTableHeaderView *refreshHeaderView;
    MBProgressHUD *HUD;
}

@synthesize buttonWeekly;
@synthesize buttonMonthly;
@synthesize buttonCalendar;
@synthesize viewTab;
@synthesize loadIndicator;
@synthesize buttonNavLeft;
@synthesize buttonDaily;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:@"BecomeActive" object:nil];
    
    loadEnded = FALSE;
    ranktype = @"calendar";
    rankpage = 1;
    
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Ranking Screen"];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.tableView];
    [self.tableView addSubview:HUD];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = NSLocalizedString(@"Loading...", @"Loading...") ;
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    HUD.margin = 10.f;
    HUD.yOffset = 150.f;
    
    rankLayout = kLayoutCalendar;
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tableView addSubview:refreshHeaderView];
    
    [self loadCalendar];
}

- (void)becomeActive:(id)sender {
    [self reloadTableViewDataSource];
    rankpage = 1;
    [self loadRanking];
}


- (void)loadCalendar {
    NSString* url = [NSString stringWithFormat:@"picture/ranking/calendar"];
    
    [loadIndicator startAnimating];
    [HUD show:YES];
    loadEnded = false;
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       days = [JSON objectForKey:@"days"];
                                       rankLayout = kLayoutCalendar;
                                       
                                       [self.tableView reloadData];
                                       [self doneLoadingTableViewData];
                                       [loadIndicator stopAnimating];
                                       [HUD hide:YES];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Ranking)");
                                       [self doneLoadingTableViewData];
                                       [loadIndicator stopAnimating];
                                       [HUD hide:YES];
                                       loadEnded = true;
                                   }
     ];
}

- (void)loadRanking {
    NSString* url = [NSString stringWithFormat:@"picture/ranking/%@/%d", ranktype, rankpage];
    
    [loadIndicator startAnimating];
    [HUD show:YES];
    loadEnded = false;
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       pics = [Picture mutableArrayFromDictionary:JSON withKey:@"pics"];
                                       rankLayout = kLayoutNormal;
                                       [self.tableView reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                       [loadIndicator stopAnimating];
                                       [HUD hide:YES];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Ranking)");
                                       [self doneLoadingTableViewData];
                                       [loadIndicator stopAnimating];
                                       [HUD hide:YES];
                                       loadEnded = true;
                                   }
     ];
}

- (void)loadMore {
    rankpage += 1;
    NSString* url = [NSString stringWithFormat:@"picture/ranking/%@/%d", ranktype, rankpage];
    
    [loadIndicator startAnimating];
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    [self.tableView beginUpdates];
    [[LatteAPIClient sharedClient] getPath:url
                                parameters:[NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
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
    
    buttonDaily.selected = false;
    buttonWeekly.selected = false;
    buttonMonthly.selected = false;
    buttonCalendar.selected = false;
    
    sender.selected = true;
    
    switch (sender.tag) {
        case 1:{
            ranktype = @"calendar";
            rankpage = 1;
            [self loadCalendar];
        }
            break;
        case 2: {
            ranktype = @"daily";
            rankpage = 1;
            [self loadRanking];
        }
            break;
        case 3: {
            ranktype = @"weekly";
            rankpage = 1;
            [self loadRanking];
        }
            break;
        case 4: {
            ranktype = @"monthly";
            rankpage = 1;
            [self loadRanking];
        }
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (rankLayout == kLayoutNormal) {
        NSInteger count = pics.count;
        if (count > 1) {
            NSInteger ret = (count - 1) / 3 + ((count-1)%3>0?1:0);
            return ret;
        }
        else if (count == 1)
            return 1;
        else
            return 0;
    } else {
        NSDictionary *dayInfo = days[section];
        NSArray *pictures = [dayInfo objectForKey:@"pictures"];
        return pictures.count/3 + (pictures.count%3>0?1:0);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (rankLayout == kLayoutCalendar)
        return days.count;
    else
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
    if (rankLayout == kLayoutNormal) {
        
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
    } else {
        NSDictionary *dayInfo = days[indexPath.section];
        NSArray *pictures = [Picture mutableArrayFromDictionary:dayInfo withKey:@"pictures"];
        
        LXCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:@"Grid" forIndexPath:indexPath];
        [cell setPictures:pictures forRow:indexPath.row];
        
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (rankLayout == kLayoutCalendar) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
        label.textColor = [UIColor whiteColor];
        
        NSDictionary *dayInfo = days[section];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyyMMdd"];
        NSDate *myDate = [df dateFromString:[dayInfo objectForKey:@"day"]];
        [df setDateFormat:@"yyyy/MM/dd"];
        label.text = [df stringFromDate:myDate];
        return label;
    } else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (rankLayout == kLayoutCalendar) {
        return 30;
    } else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (rankLayout == kLayoutCalendar) {
        return 104;
    } else {
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
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    viewGallery.picture = [[pics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pictureId == %d", buttonImage.tag]]] lastObject];
    [self presentViewController:navGalerry animated:YES completion:nil];
}

- (NSDictionary *)pictureAfterPicture:(Picture *)picture {
    NSUInteger current = [pics indexOfObject:picture];
    if (current < pics.count-1) {
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             pics[current+1],  @"picture",
                             nil];
        return ret;
    }
    return nil;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {
    NSUInteger current = [pics indexOfObject:picture];
    if (current > 0) {
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             pics[current-1],  @"picture",
                             nil];
        return ret;
    }
    return nil;
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
