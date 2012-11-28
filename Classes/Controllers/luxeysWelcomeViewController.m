//
//  luxeysWelcomeViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/8/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysWelcomeViewController.h"

@interface luxeysWelcomeViewController ()
@end

@implementation luxeysWelcomeViewController

@synthesize buttonLeftMenu;
@synthesize buttonNavRight;
@synthesize tablePic;
@synthesize viewHeader;
@synthesize buttonGrid;
@synthesize buttonTimeline;
@synthesize viewBack;
@synthesize viewLogin;
@synthesize indicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveLoggedIn:)
                                                     name:@"NoConnection"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveLoggedOut:)
                                                     name:@"ConnectedInternet"
                                                   object:nil];
        
        loadEnded = false;
        pagephoto = 1;
        tableMode = kTableGrid;
    }
    
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    viewBack.layer.cornerRadius = 5;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 40, 320, 10);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor clearColor] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2f] CGColor],
                       nil];
    [viewHeader.layer insertSublayer:gradient atIndex:0];
    
    tablePic.frame = CGRectMake(0, 0, 320, self.view.frame.size.height-44);
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tablePic.bounds.size.height, self.view.frame.size.width, tablePic.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tablePic addSubview:refreshHeaderView];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self reloadView];

    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [viewLogin removeFromSuperview];
    [self.navigationController.view addSubview:viewLogin];
    if ([app getToken].length == 0) {
        viewLogin.hidden = false;
    }
    navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.revealController action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    navigationBarPanGestureRecognizer.enabled = false;

    [self.buttonLeftMenu addTarget:app.revealController action:@selector(revealLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonNavRight addTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)reloadView {
    loadEnded = false;
    pagephoto = 1;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[LatteAPIClient sharedClient] getPath:@"api/user/everyone/timeline"
                                          parameters:nil
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 feeds = [Feed mutableArrayFromDictionary:JSON withKey:@"feeds"];

                                                 [tablePic reloadData];
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                                 
                                                 [self doneLoadingTableViewData];
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                                 
                                                 [self doneLoadingTableViewData];
                                                 
                                                 NSLog(@"Something went wrong (Welcome)");
                                             }];
    });
}

- (void)loadMore {
    [indicator startAnimating];
    
    [[LatteAPIClient sharedClient] getPath:@"api/user/everyone/timeline"
                                parameters: [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:pagephoto+1]
                                                                        forKey:@"page"]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       
                                       pagephoto += 1;
                                       NSMutableArray *newFeeds = [Feed mutableArrayFromDictionary:JSON withKey:@"feeds"];
                                       
                                       if (newFeeds.count > 0) {
                                           NSInteger oldRow = [self tableView:tablePic numberOfRowsInSection:0];
                                           [tablePic beginUpdates];
                                           [feeds addObjectsFromArray:newFeeds];
                                           NSInteger newRow = [self tableView:tablePic numberOfRowsInSection:0];
                                           for (NSInteger i = oldRow; i < newRow; i++) {
                                               [tablePic insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]
                                                               withRowAnimation:UITableViewRowAnimationAutomatic];
                                           }

                                           [tablePic endUpdates];
                                       } else {
                                           loadEnded = true;
                                       }
                                       
                                       [indicator stopAnimating];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Something went wrong (Welcome)");
                                       [indicator stopAnimating];
                                   }];
}

#pragma mark - SSCollectionViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableMode == kTableTimeline)
        return feeds.count;
    else
        return feeds.count/3 + (feeds.count%3>0?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTableTimeline) {
        Feed *feed = feeds[indexPath.row];
        if (feed.targets.count == 1) {
            luxeysCellWelcomeSingle *cell = [tableView dequeueReusableCellWithIdentifier:@"Single" forIndexPath:indexPath];
            if (nil == cell) {
                cell = [[luxeysCellWelcomeSingle alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"Single"];
            }
            
            cell.viewController = self;
            cell.feed = feed;

            return cell;
        } else {
            luxeysCellWelcomeMulti *cell = [tableView dequeueReusableCellWithIdentifier:@"Multi" forIndexPath:indexPath];
            if (nil == cell) {
                cell = [[luxeysCellWelcomeMulti alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:@"Multi"];
            }
            
            cell.showControl = false;
            cell.viewController = self;
            cell.feed = feed;
            
            return cell;
        }
    
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Grid" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Grid"];
        }
        
        for(UIView *subview in [cell subviews]) {
            [subview removeFromSuperview];
        }
        
        for (int i=0; i < 3; i++) {
            NSInteger idx = indexPath.row*3 + i;
            if (idx < feeds.count) {
                
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6 + 104*i, (indexPath.row==0?6:3),98, 98)];
                Feed *feed = feeds[idx];
                
                if (feed.targets.count > 0) {
                    Picture *pic = feed.targets[0];
                    
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
                    
                    [button loadBackground:pic.urlSquare];
                    [button addTarget:self action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:button];
                }
            }
        }
        cell.clipsToBounds = false;
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTableTimeline) {
        Feed *feed = feeds[indexPath.row];
        if (feed.targets.count > 1) {
            return 239;
        } else if (feed.targets.count == 1) {
            Picture *pic = feed.targets[0];
            CGFloat picHeight = [luxeysUtils heightFromWidth:308 width:[pic.width floatValue] height:[pic.height floatValue]];
            return picHeight + 49;
        } else
            return 1;
    } else
        return 104 + (indexPath.row==0?3:0);
}

- (void)showPic:(UIButton*)sender {
    [self performSegueWithIdentifier:@"PictureDetail" sender:sender];
}

- (void)showUser:(UIButton*)sender {
    [self performSegueWithIdentifier:@"UserDetail" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        [viewPicDetail setPictureID:sender.tag];
    } else if ([segue.identifier isEqualToString:@"UserDetail"]) {
        luxeysUserViewController* viewUserDetail = segue.destinationViewController;
        [viewUserDetail setUserID:sender.tag];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSUInteger)section {
    return 40.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    [view addSubview:indicator];
    return view;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideLoginPanel];
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    navigationBarPanGestureRecognizer.enabled = true;
    
    buttonLeftMenu.hidden = false;
    buttonNavRight.hidden = true;
    
    [self hideLoginPanel];
}

- (void)receiveLoggedOut:(NSNotification *) notification {
    navigationBarPanGestureRecognizer.enabled = false;
    
    buttonLeftMenu.hidden = true;
    buttonNavRight.hidden = false;
}

- (void)loginPressed:(id)sender {
    [self performSegueWithIdentifier:@"Login" sender:self];
}

- (IBAction)touchTab:(UIButton*)sender {
    buttonGrid.enabled = true;
    buttonTimeline.enabled = true;
    sender.enabled = false;
    
    switch (sender.tag) {
        case 0:
            tableMode = kTableGrid;
            break;
        case 1:
            tableMode = kTableTimeline;
            break;
        default:
            break;
    }
    [tablePic reloadData];
}

- (void)hideLoginPanel {
    [UIView animateWithDuration:0.3 animations:^{
        viewLogin.alpha = 0;
    } completion:^(BOOL finished) {
        viewLogin.hidden = true;
    }];
}
- (IBAction)touchCloseLogin:(id)sender {
    [self hideLoginPanel];
}

- (IBAction)touchReg:(id)sender {
    [self performSegueWithIdentifier:@"Register" sender:nil];
}

- (IBAction)touchLogin:(id)sender {
    [self performSegueWithIdentifier:@"Login" sender:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [refreshHeaderView egoRefreshScrollViewDidScroll:aScrollView];

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
        if (!indicator.isAnimating) {
            [self loadMore];
        }
    }
}

- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tablePic];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    
    [self reloadView];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setButtonLeftMenu:nil];
    [self setButtonNavRight:nil];
    [self setTablePic:nil];
    [self setButtonGrid:nil];
    [self setButtonTimeline:nil];
    [self setViewHeader:nil];
    [self setViewBack:nil];
    [self setViewLogin:nil];
    [self setIndicator:nil];
    [super viewDidUnload];
}
@end
