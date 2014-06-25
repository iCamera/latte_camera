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
#import "Picture.h"
#import "LXCellRankLv1.h"
#import "LXCellRankLv2.h"
#import "UIButton+AFNetworking.h"
#import "LXUtils.h"
#import "LatteAPIClient.h"
#import "LXUserPageViewController.h"
#import "REFrostedViewController.h"
#import "MZFormSheetSegue.h"

typedef enum {
    kLayoutNormal,
    kLayoutCalendar,
} RankingPage;

@interface LXRankingViewController ()

@end

@implementation LXRankingViewController {
    BOOL loadEnded;
    NSString* ranktype;
    int rankpage;
    NSMutableArray *pics;
    NSMutableArray *days;
    NSInteger rankLayout;
    BOOL reloading;
    NSString *browsingCountry;
}

@synthesize buttonWeekly;
@synthesize buttonMonthly;
@synthesize buttonCalendar;
@synthesize viewTab;
@synthesize loadIndicator;
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
    ranktype = @"trend";
    rankpage = 1;
    
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [app.tracker set:kGAIScreenName
               value:@"Ranking Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    rankLayout = kLayoutNormal;
    
    // Do any additional setup after loading the view.
    
    //setup left button
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changedBrowsingCountry:)
                                                 name:@"ChangedBrowsingCountry" object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    browsingCountry = [defaults objectForKey:@"BrowsingCountry"];
    if (browsingCountry) {
        NSString *countryImage = [NSString stringWithFormat:@"%@.png", browsingCountry];
        [_buttonCountry setImage:[UIImage imageNamed:countryImage] forState:UIControlStateNormal];
    }
    
    [self reloadView];
}

- (void)becomeActive:(id)sender {
    [self reloadView];
}

- (void)changedBrowsingCountry:(NSNotification*)notify {
    browsingCountry = notify.object;
    NSString *countryImage;
    if (browsingCountry && [browsingCountry isEqualToString:@"World"]) {
        countryImage = @"icon_area.png";
    } else {
        countryImage = [NSString stringWithFormat:@"%@.png", browsingCountry];
    }
    [_buttonCountry setImage:[UIImage imageNamed:countryImage] forState:UIControlStateNormal];
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
    loadEnded = false;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    if (browsingCountry) {
        param[@"country"] = browsingCountry;
    }
    
    [[LatteAPIClient sharedClient] GET:url
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
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Ranking)");
                                       [loadIndicator stopAnimating];
                                       loadEnded = true;
                                   }
     ];
}

- (void)loadMoreCalendar {
    rankpage += 1;
    NSString* url = [NSString stringWithFormat:@"picture/ranking/calendar/%d", rankpage];
    
    [loadIndicator startAnimating];
    loadEnded = false;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    if (browsingCountry) {
        param[@"country"] = browsingCountry;
    }
    
    [[LatteAPIClient sharedClient] GET:url
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       
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
                                       loadEnded = true;
                                   }
     ];
}

- (void)loadRanking {
    NSString* url = [NSString stringWithFormat:@"picture/ranking/%@/%ld", ranktype, rankpage];
    
    [loadIndicator startAnimating];
    loadEnded = false;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    if (browsingCountry) {
        param[@"country"] = browsingCountry;
    }
    
    [[LatteAPIClient sharedClient] GET:url
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       pics = [Picture mutableArrayFromDictionary:JSON withKey:@"pics"];
                                       rankLayout = kLayoutNormal;
                                       [self.tableView reloadData];
                                       [loadIndicator stopAnimating];
                                       [self.refreshControl endRefreshing];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Ranking)");
                                       [loadIndicator stopAnimating];
                                       [self.refreshControl endRefreshing];
                                       loadEnded = true;
                                   }
     ];
}

- (void)loadMoreNormal {
    rankpage += 1;
    NSString* url = [NSString stringWithFormat:@"picture/ranking/%@/%ld", ranktype, rankpage];
    
    [loadIndicator startAnimating];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    if (browsingCountry) {
        param[@"country"] = browsingCountry;
    }
    
    [[LatteAPIClient sharedClient] GET:url
                                parameters:param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       [self.tableView beginUpdates];
                                       NSInteger rowCountPrev = [self.tableView numberOfRowsInSection:0];
                                       NSArray *newPics = [JSON objectForKey:@"pics"];
                                       for (NSDictionary *pic in newPics) {
                                           [pics addObject:[Picture instanceFromDictionary:pic]];
                                       }
                                       
                                       if (newPics.count == 0)
                                           loadEnded = true;
                                       else {
                                           NSInteger newRows = [self tableView:self.tableView numberOfRowsInSection:0] - rowCountPrev;
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

- (IBAction)touchTab:(UISegmentedControl*)sender {
    loadEnded = false;
    
    buttonDaily.selected = false;
    buttonWeekly.selected = false;
    buttonMonthly.selected = false;
    buttonCalendar.selected = false;
    
    sender.selected = true;
    
    switch (sender.selectedSegmentIndex) {
        case 0:{
            ranktype = @"calendar";
            rankpage = 1;
            [self loadCalendar];
        }
            break;
        case 1: {
            ranktype = @"trend";
            rankpage = 1;
            [self loadRanking];
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
    button.layer.cornerRadius = 2;
    button.layer.masksToBounds = YES;
    
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
            frame.size.height = [LXUtils heightFromWidth:320
                                                   width:[pic.width floatValue]
                                                  height:[pic.height floatValue]];
            cellLv1.buttonPic1.frame = frame;
            [cellLv1.buttonPic1 addTarget:self action:@selector(didSelectPic:) forControlEvents:UIControlEventTouchUpInside];
            
            [cellLv1.buttonPic1 setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlMedium] placeholderImage:nil];

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
                [cellLv2.buttonPic2 setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlSquare] placeholderImage:nil];
                
                cellLv2.buttonPic2.tag = [pic.pictureId integerValue];
                cellLv2.label1st.text = [NSString stringWithFormat:@"%ld", baseIdx+1];
                if (baseIdx == 1)
                    [cellLv2.imageBg1 setImage:[UIImage imageNamed:@"bg_rank2.png"]];
                else
                    [cellLv2.imageBg1 setImage:[UIImage imageNamed:@"bg_rank3-9.png"]];
            }
            
            if (pics.count > baseIdx  + 3) {
                Picture *pic = [pics objectAtIndex:baseIdx + 1];

                [cellLv2.buttonPic3 setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlSquare] placeholderImage:nil];
                cellLv2.buttonPic3.tag = [pic.pictureId integerValue];
                cellLv2.label2nd.text = [NSString stringWithFormat:@"%ld", baseIdx+2];
                if (baseIdx == 2)
                    [cellLv2.imageBg2 setImage:[UIImage imageNamed:@"bg_rank3.png"]];
                else
                    [cellLv2.imageBg2 setImage:[UIImage imageNamed:@"bg_rank3-9.png"]];
            }
            
            if (pics.count > baseIdx  + 4) {
                Picture *pic = [pics objectAtIndex:baseIdx + 2];
                [cellLv2.buttonPic4 setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlSquare] placeholderImage:nil];
                cellLv2.buttonPic4.tag = [pic.pictureId integerValue];
                cellLv2.label3rd.text = [NSString stringWithFormat:@"%ld", baseIdx+3];
            }
            
            return cellLv2;
        }
    } else {
        NSDictionary *dayInfo = days[indexPath.section];
        NSArray *pictures = dayInfo[@"pictures"];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Grid"];

        for(UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
        
        for (int i = 0; i < 3; ++i)
        {
            NSInteger index = indexPath.row*3+i;
            
            Picture *pic;
            if (index >= pictures.count)
                break;
            pic = pictures[index];
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6 + 104*i, 3, 100, 100)];
            
            [button setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlSquare] placeholderImage:nil];

            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 2;
            
            button.tag = [pic.pictureId integerValue];
            [button addTarget:self action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
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
    Picture *pic = [[pics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pictureId == %ld", sender.tag]]] lastObject];
    
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
            
            float newheight = [LXUtils heightFromWidth:320
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
    viewGallery.picture = [[pics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pictureId == %ld", buttonImage.tag]]] lastObject];
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

- (void)showUser:(User *)user fromGallery:(LXGalleryViewController *)gallery {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
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



- (IBAction)refresh:(id)sender {
    [self reloadView];
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


@end
