//
//  luxeysRankingViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/4/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysRankingViewController.h"
#import "luxeysCellRankLv1.h"
#import "luxeysCellRankLv2.h"
#import "luxeysCellRankLv3.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysImageUtils.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysPicDetailViewController.h"

@interface luxeysRankingViewController ()

@end

@implementation luxeysRankingViewController
@synthesize buttonDaily;
@synthesize buttonWeekly;
@synthesize buttonMonthly;
@synthesize tableRank;
@synthesize viewTab;
@synthesize viewScroll;
@synthesize arPics;

NSString* ranktype = @"daily";
NSInteger rankpage = 1;
BOOL loadingrank = FALSE;

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
    UIBezierPath *shadowPath2 = [UIBezierPath bezierPathWithRect:tableRank.bounds];
    tableRank.layer.masksToBounds = NO;
    tableRank.layer.shadowColor = [UIColor blackColor].CGColor;
    tableRank.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    tableRank.layer.shadowOpacity = 0.5f;
    tableRank.layer.shadowRadius = 2.0f;
    tableRank.layer.shadowPath = shadowPath2.CGPath;
    
    [self loadRanking];
}

- (void)viewDidUnload
{
    [self setButtonDaily:nil];
    [self setButtonWeekly:nil];
    [self setButtonMonthly:nil];
    [self setTableRank:nil];
    [self setViewTab:nil];
    [self setViewScroll:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)loadRanking {
    NSString* url = [NSString stringWithFormat:@"api/picture/ranking/%@/%d", ranktype, rankpage];
    
    loadingrank = TRUE;
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters: nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             arPics = [[NSMutableArray alloc] initWithArray:[JSON objectForKey:@"pics"]];
                                             [tableRank reloadData];
                                             
                                             CGRect frame = tableRank.frame;
                                             frame.size.height = tableRank.contentSize.height;
                                             tableRank.frame = frame;
                                             viewScroll.contentSize = CGSizeMake(320, tableRank.contentSize.height + viewTab.frame.size.height);
                                             loadingrank = FALSE;
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Ranking)");
                                         }
     ];
}

- (void)loadMore {
    rankpage += 1;
    NSString* url = [NSString stringWithFormat:@"api/picture/ranking/%@/%d", ranktype, rankpage];
    
    loadingrank = TRUE;
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters: nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             NSArray *arNew = [JSON objectForKey:@"pics"];

                                             if (arNew != NULL) {
                                                 [arPics addObjectsFromArray:arNew];
                                                 [tableRank reloadData];
                                                 
                                                 CGRect frame = tableRank.frame;
                                                 frame.size = tableRank.contentSize;
                                                 tableRank.frame = frame;
                                                 viewScroll.contentSize = CGSizeMake(320, tableRank.contentSize.height + viewTab.frame.size.height);
                                                 
                                                 loadingrank =  FALSE;
                                             }
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Ranking)");
                                         }
     ];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)touchTab:(UIButton*)sender {
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
    NSInteger count = [arPics count];
    if (count > 4) {
        NSInteger ret = (count - 4) / 4 + 2;
        return ret;
    }
    else if (count > 1)
        return 2;
    else if (count == 1)
        return 1;
    else
        return 0;
    
}

- (void)initButton:(UIButton*)button index:(NSInteger)index {
    NSDictionary *dictPic = [arPics objectAtIndex:index];
    NSString* url;
    if (index == 0)
        url = [dictPic objectForKey:@"url_medium"];
    else
        url = [dictPic objectForKey:@"url_square"];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    UIImageView* imageFirst = [[UIImageView alloc] init];
    [imageFirst setImageWithURLRequest:theRequest
                      placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   [button setBackgroundImage:image forState:UIControlStateNormal];
                               }
                               failure:nil
     ];
    button.tag = index;
    [button addTarget:self action:@selector(didSelectPic:) forControlEvents:UIControlEventTouchUpInside];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        luxeysCellRankLv1 *cellLv1 = [tableView dequeueReusableCellWithIdentifier:@"First"];
        if (nil == cellLv1) {
            cellLv1 = [[luxeysCellRankLv1 alloc] initWithStyle:UITableViewCellStyleDefault
                                                                     reuseIdentifier:@"First"];
        }
        
            NSDictionary *dictPic = [arPics objectAtIndex:0];
            
            float newheight = [luxeysImageUtils heightFromWidth:300
                                                          width:[[dictPic objectForKey:@"width"] floatValue]
                                                         height:[[dictPic objectForKey:@"height"] floatValue]];
            
            cellLv1.buttonPic1.frame = CGRectMake(cellLv1.buttonPic1.frame.origin.x,
                                                  cellLv1.buttonPic1.frame.origin.y,
                                                  300,
                                                  newheight);
            
        [self initButton:cellLv1.buttonPic1 index:0];
        
        return cellLv1;
    } else if (indexPath.row == 1) {
        luxeysCellRankLv2 *cellLv2 = [tableView dequeueReusableCellWithIdentifier:@"Second"];
        if (nil == cellLv2) {
            cellLv2 = [[luxeysCellRankLv2 alloc] initWithStyle:UITableViewCellStyleDefault
                                                                     reuseIdentifier:@"Second"];
        }
            
            [self initButton:cellLv2.buttonPic2 index:1];
            
            
            if ([arPics count] > 2) {
                [self initButton:cellLv2.buttonPic3 index:2];
            }
            
            if ([arPics count] > 3) {
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
        
        if ([arPics count] > (indexPath.row-2)*4+5) {
            [self initButton:cellLv3.buttonPic2 index:(indexPath.row-2)*4+5];
        }
        
        if ([arPics count] > (indexPath.row-2)*4+6) {
            [self initButton:cellLv3.buttonPic3 index:(indexPath.row-2)*4+6];
        }
        
        
        if ([arPics count] > (indexPath.row-2)*4+7) {
            [self initButton:cellLv3.buttonPic4 index:(indexPath.row-2)*4+7];
        }
        
        return cellLv3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSDictionary *dictPic = [arPics objectAtIndex:0];
        
        float newheight = [luxeysImageUtils heightFromWidth:300
                                                      width:[[dictPic objectForKey:@"width"] floatValue]
                                                     height:[[dictPic objectForKey:@"height"] floatValue]];
        return newheight + 10;
    }
    else if (indexPath.row == 1)
        return 103;
    else
        return 78;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //Load more
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 10;
    if(y > h + reload_distance) {
        if (!loadingrank) {
            [self loadMore];
        }
    }
}

- (void)didSelectPic:(UIButton*)buttonImage {
    [self performSegueWithIdentifier:@"PictureDetail" sender:[arPics objectAtIndex:buttonImage.tag]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        viewPicDetail.picInfo = sender;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

@end
