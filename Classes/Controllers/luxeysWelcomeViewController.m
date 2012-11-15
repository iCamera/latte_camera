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
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.hidesWhenStopped = true;
        [indicator setCenter:CGPointMake(160, 20)];
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
                                           [feeds addObjectsFromArray:newFeeds];
                                           [tablePic reloadData];
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
            Picture *pic = feed.targets[0];
            CGRect frame = cell.buttonPic.frame;
            frame.size.height = [luxeysUtils heightFromWidth:300 width:[pic.width floatValue] height:[pic.height floatValue]];
            cell.buttonPic.frame = frame;
            cell.buttonPic.layer.borderColor = [[UIColor whiteColor] CGColor];
            cell.buttonPic.layer.borderWidth = 3;
            UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:cell.buttonPic.bounds];
            cell.buttonPic.layer.masksToBounds = NO;
            cell.buttonPic.layer.shadowColor = [UIColor blackColor].CGColor;
            cell.buttonPic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
            cell.buttonPic.layer.shadowOpacity = 0.5f;
            cell.buttonPic.layer.shadowRadius = 1.5f;
            cell.buttonPic.layer.shadowPath = shadowPathPic.CGPath;
            [cell.buttonPic loadBackground:pic.urlMedium];
            cell.buttonPic.tag = [pic.pictureId integerValue];
            
            cell.buttonUser.clipsToBounds = YES;
            cell.buttonUser.layer.cornerRadius = 3;
            cell.buttonUser.tag = [feed.user.userId integerValue];
            [cell.buttonUser loadBackground:feed.user.profilePicture placeholderImage:@"user.gif"];
            if (pic.title.length > 0)
                cell.labelTitle.text = pic.title;
            else
                cell.labelTitle.text = @"タイトルなし";
            cell.labelUser.text = [NSString stringWithFormat:@"photo by %@ | %@", feed.user.name, [luxeysUtils timeDeltaFromNow:feed.updatedAt]];
            
            cell.clipsToBounds = NO;
            
            [cell.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonPic addTarget:self action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        } else {
            luxeysCellWelcomeMulti *cell = [tableView dequeueReusableCellWithIdentifier:@"Multi" forIndexPath:indexPath];
            if (nil == cell) {
                cell = [[luxeysCellWelcomeMulti alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:@"Multi"];
            }
            [cell.buttonUser loadBackground:feed.user.profilePicture placeholderImage:@"user.gif"];
            
            for(UIView *subview in [cell.scrollPic subviews]) {
                [subview removeFromSuperview];
            }
            
            CGSize size = CGSizeMake(6, 120);
            for (Picture *pic in feed.targets) {
                UIButton *buttonPic = [[UIButton alloc] initWithFrame:CGRectMake(size.width, 2, 120, 120)];
                buttonPic.layer.borderColor = [[UIColor whiteColor] CGColor];
                buttonPic.layer.borderWidth = 3;
                UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonPic.bounds];
                buttonPic.layer.masksToBounds = NO;
                buttonPic.layer.shadowColor = [UIColor blackColor].CGColor;
                buttonPic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
                buttonPic.layer.shadowOpacity = 0.5f;
                buttonPic.layer.shadowRadius = 1.5f;
                buttonPic.layer.shadowPath = shadowPathPic.CGPath;
                
                [buttonPic loadBackground:pic.urlSquare];
                buttonPic.tag = [pic.pictureId integerValue];
                
                [buttonPic addTarget:self action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.scrollPic addSubview:buttonPic];
                size.width += 126;
            }
            cell.scrollPic.contentSize = size;
            cell.scrollPic.clipsToBounds = NO;
            cell.buttonUser.clipsToBounds = YES;
            cell.buttonUser.layer.cornerRadius = 3;
            cell.buttonUser.tag = [feed.user.userId integerValue];
            
            cell.labelTitle.text = [NSString stringWithFormat:@"写真を%d枚追加しました", feed.targets.count];
            cell.labelUserDate.text = [NSString stringWithFormat:@"photo by %@ | %@", feed.user.name, [luxeysUtils timeDeltaFromNow:feed.updatedAt]];
            
            [cell.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:cell.scrollPic];
            
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
                
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6 + 102*i, (indexPath.row==0?6:0),99, 99)];
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
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTableTimeline) {
        Feed *feed = feeds[indexPath.row];
        if (feed.targets.count > 1) {
            return 180;
        } else if (feed.targets.count == 1) {
            Picture *pic = feed.targets[0];
            CGFloat picHeight = [luxeysUtils heightFromWidth:300 width:[pic.width floatValue] height:[pic.height floatValue]];
            return picHeight + 55;
        } else
            return 1;
    } else
        return 105 + (indexPath.row==0?6:0);
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
    [super viewDidUnload];
}
@end
