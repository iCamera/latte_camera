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
#import "MBProgressHUD.h"
#import "Picture.h"
#import "LXCellRankLv1.h"
#import "LXCellRankLv2.h"
#import "UIButton+AsyncImage.h"
#import "LXUtils.h"
#import "LatteAPIClient.h"


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
    MBProgressHUD *HUD;
    NSString *area;
}

@synthesize buttonWeekly;
@synthesize buttonMonthly;
@synthesize buttonCalendar;
@synthesize viewTab;
@synthesize loadIndicator;
@synthesize buttonDaily;
@synthesize buttonAreaLocal;
@synthesize buttonAreaWorld;

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
    ranktype = @"trend";
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
    
    rankLayout = kLayoutNormal;
    
    // Do any additional setup after loading the view.
//    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    //setup left button
    UIBarButtonItem *navLeftItem = self.navigationItem.leftBarButtonItem;
    UIButton *buttonSide = (UIButton*)navLeftItem.customView;
//    [buttonSide addTarget:app.controllerSide action:@selector(toggleLeftPanel:) forControlEvents:UIControlEventTouchUpInside];
    
    area = [[NSUserDefaults standardUserDefaults] objectForKey:@"timeline_area"];
    if (!area) {
        area = @"local";
    }
    
    if ([area isEqualToString:@"world"]) {
        buttonAreaWorld.selected = YES;
        buttonAreaLocal.selected = NO;
    } else {
        buttonAreaWorld.selected = NO;
        buttonAreaLocal.selected = YES;
    }
    
    [self reloadView];
}

- (void)becomeActive:(id)sender {
    [self reloadView];
}

- (void)reloadView {
    rankpage = 1;
    if (rankLayout == kLayoutNormal) {
        [self loadRanking];
    } else {
        [self loadCalendar];
    }
}

- (void)loadMore {
    if (loadIndicator.isAnimating || loadEnded) {
        return;
    }

    switch (rankLayout) {
        case kLayoutCalendar:
            [self loadMoreCalendar];
            break;
        case kLayoutNormal:
            [self loadMoreNormal];
            break;
        default:
            break;
    }
}


- (void)loadCalendar {
    NSString* url = [NSString stringWithFormat:@"picture/ranking/calendar"];
    
    [loadIndicator startAnimating];
    [HUD show:YES];
    loadEnded = false;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:area forKey:@"area"];
    
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       days = [[NSMutableArray alloc] init];
                                       for (NSDictionary *day in JSON[@"days"]) {
                                           NSMutableDictionary *dayInfo = [day mutableCopy];
                                           [dayInfo setObject:[Picture mutableArrayFromDictionary:day withKey:@"pictures"] forKey:@"pictures"];
                                           [days addObject:dayInfo];
                                       }
                                       
                                       pics = [self flatPictureArray];
                                       rankLayout = kLayoutCalendar;
                                       
                                       [self.tableView reloadData];
                                       [loadIndicator stopAnimating];
                                       [HUD hide:YES];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Ranking)");
                                       [loadIndicator stopAnimating];
                                       [HUD hide:YES];
                                       loadEnded = true;
                                   }
     ];
}

- (void)loadMoreCalendar {
    rankpage += 1;
    NSString* url = [NSString stringWithFormat:@"picture/ranking/calendar/%d", rankpage];
    
    [loadIndicator startAnimating];
    [HUD show:YES];
    loadEnded = false;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:area forKey:@"area"];
    
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       [HUD hide:YES];
                                       
                                       NSArray *newDays = [JSON objectForKey:@"days"];
                                       if (newDays.count == 0) {
                                           loadEnded = true;
                                       }
                                       else {
                                           
                                           for (NSDictionary *day in JSON[@"days"]) {
                                               NSMutableDictionary *dayInfo = [day mutableCopy];
                                               [dayInfo setObject:[Picture mutableArrayFromDictionary:day withKey:@"pictures"] forKey:@"pictures"];
                                               [days addObject:dayInfo];
                                           }
                                           
                                           pics = [self flatPictureArray];
                                           [self.tableView reloadData];
                                       }
                                       
                                       [loadIndicator stopAnimating];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Ranking)");
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
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:area forKey:@"area"];
    
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       pics = [Picture mutableArrayFromDictionary:JSON withKey:@"pics"];
                                       rankLayout = kLayoutNormal;
                                       [self.tableView reloadData];
                                       [loadIndicator stopAnimating];
                                       [HUD hide:YES];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Ranking)");
                                       [loadIndicator stopAnimating];
                                       [HUD hide:YES];
                                       loadEnded = true;
                                   }
     ];
}

- (void)loadMoreNormal {
    rankpage += 1;
    NSString* url = [NSString stringWithFormat:@"picture/ranking/%@/%d", ranktype, rankpage];
    
    [loadIndicator startAnimating];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:area forKey:@"area"];
    
    [[LatteAPIClient sharedClient] getPath:url
                                parameters:param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       [self.tableView beginUpdates];
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
                                       DLog(@"Something went wrong (Ranking)");
                                       [loadIndicator stopAnimating];
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
            ranktype = @"trend";
            rankpage = 1;
            [self loadRanking];
        }
            break;
        case 3: {
            ranktype = @"daily";
            rankpage = 1;
            [self loadRanking];
        }
            break;
        case 4: {
            ranktype = @"weekly";
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
                DLog(@"New row");
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
        NSArray *pictures = dayInfo[@"pictures"];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Grid"];

        for(UIView *subview in [cell subviews]) {
            [subview removeFromSuperview];
        }
        
        for (int i = 0; i < 3; ++i)
        {
            NSInteger index = indexPath.row*3+i;
            
            Picture *pic;
            if (index >= pictures.count)
                break;
            pic = pictures[index];
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6 + 104*i, 3, 98, 98)];
            
            [button loadBackground:pic.urlSquare];
            button.layer.borderColor = [[UIColor whiteColor] CGColor];
            button.layer.borderWidth = 3;
            
            UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:button.bounds];
            button.layer.masksToBounds = NO;
            button.layer.shadowColor = [UIColor blackColor].CGColor;
            button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
            button.layer.shadowOpacity = 0.5f;
            button.layer.shadowRadius = 1.5f;
            button.layer.shadowPath = shadowPath.CGPath;
            
            button.tag = [pic.pictureId integerValue];
            [button addTarget:self action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
        }
        
        return cell;
    }
}

- (NSMutableArray*)flatPictureArray {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (NSDictionary *day in days) {
        for (Picture *pic in [day objectForKey:@"pictures"]) {
            [ret addObject:pic];
        }
    }
    return ret;
}


- (void)showPic:(UIButton *)sender {
    Picture *pic = [[pics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pictureId == %d", sender.tag]]] lastObject];
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    viewGallery.picture = pic;
    [self presentViewController:navGalerry animated:YES completion:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (rankLayout == kLayoutCalendar) {
        UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        UIImageView *imageRank = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        imageRank.contentMode = UIViewContentModeCenter;
        imageRank.image = [UIImage imageNamed:@"icon_rank_m_white.png"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(27, 0, 293, 30)];
        viewHeader.backgroundColor = [UIColor colorWithRed:101.0/255.0 green:91.0/255.0 blue:58.0/255 alpha:0.75];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16];
        label.textColor = [UIColor whiteColor];
        
        NSDictionary *dayInfo = days[section];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyyMMdd"];
        NSDate *myDate = [df dateFromString:[dayInfo objectForKey:@"day"]];
        [df setDateFormat:@"yyyy/MM/dd"];
        label.text = [df stringFromDate:myDate];
        
        [viewHeader addSubview:label];
        [viewHeader addSubview:imageRank];
        return viewHeader;
    } else
        return [[UIView alloc] init];
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
        [self loadMore];
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
    NSInteger current = [pics indexOfObject:picture];
    if (current != NSNotFound && current < pics.count-1) {
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             pics[current+1],  @"picture",
                             nil];
        
        // Loadmore
        if (current > pics.count - 6)
            [self loadMore];
        return ret;
    }
    return nil;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {
    NSUInteger current = [pics indexOfObject:picture];
    if (current != NSNotFound && current > 0) {
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             pics[current-1],  @"picture",
                             nil];
        return ret;
    }
    return nil;
}

- (IBAction)touchArea:(UIButton*)sender {
    buttonAreaWorld.selected = NO;
    buttonAreaLocal.selected = NO;
    sender.selected = YES;
    switch (sender.tag) {
        case 0:
            area = @"local";
            break;
        case 1:
            area = @"world";
            break;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setObject:area forKey:@"timeline_area"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self reloadView];
}


@end
