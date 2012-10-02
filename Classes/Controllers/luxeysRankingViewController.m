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

@interface luxeysRankingViewController () {
    BOOL loadEnded;
    NSString* ranktype;
    NSInteger rankpage;
}

@end

@implementation luxeysRankingViewController
@synthesize buttonDaily;
@synthesize buttonWeekly;
@synthesize buttonMonthly;
@synthesize viewTab;
@synthesize arPics;
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
    
    [loadIndicator startAnimating];
    
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters: nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             arPics = [[NSMutableArray alloc] initWithArray:[JSON objectForKey:@"pics"]];
                                             [self.tableView reloadData];
                                             
                                             [loadIndicator stopAnimating];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Ranking)");
                                             [loadIndicator stopAnimating];
                                         }
     ];
}

- (void)loadMore {
    rankpage += 1;
    NSString* url = [NSString stringWithFormat:@"api/picture/ranking/%@/%d", ranktype, rankpage];
    
    [loadIndicator startAnimating];
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters: nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             NSArray *arNew = [JSON objectForKey:@"pics"];
                                             if (arNew.count == 0)
                                                 loadEnded = true;

                                             if (arNew != NULL) {
                                                 [arPics addObjectsFromArray:arNew];
                                                 [self.tableView reloadData];
                                             }
                                             
                                             [loadIndicator stopAnimating];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Ranking)");
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
    button.layer.borderColor = [[UIColor whiteColor] CGColor];
    button.layer.borderWidth = 3;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:button.bounds];
    button.layer.masksToBounds = NO;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    button.layer.shadowOpacity = 0.5f;
    button.layer.shadowRadius = 1.5f;
    button.layer.shadowPath = shadowPathPic.CGPath;
    
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
        
        cellLv3.layer.masksToBounds = NO;
        
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
        return 80;
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
        if (!loadIndicator.isAnimating) {
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

@end
