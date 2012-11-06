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
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.hidesWhenStopped = true;
        [indicator setCenter:CGPointMake(160, 20)];
    }
    
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tablePic.frame = CGRectMake(0, 0, 320, self.view.frame.size.height-44);
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tablePic.bounds.size.height, self.view.frame.size.width, tablePic.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tablePic addSubview:refreshHeaderView];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self reloadView];

    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.revealController action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    navigationBarPanGestureRecognizer.enabled = false;

    [self.buttonLeftMenu addTarget:app.revealController action:@selector(revealLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonNavRight addTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)reloadView {
    loadEnded = false;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[LatteAPIClient sharedClient] getPath:@"api/picture/latests"
                                          parameters:nil
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 items = [[NSMutableArray alloc] init];
                                                 for (NSDictionary *pic in [JSON objectForKey:@"pics"]) {
                                                     [items addObject:[Picture instanceFromDictionary:pic]];
                                                 }
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

#pragma mark - SSCollectionViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count/3 + (items.count%3>0?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    for (int i=0; i < 3; i++) {
        NSInteger idx = indexPath.row*3 + i;
        if (idx < items.count) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10 + 100*i + 2, 2,96, 96)];
            Picture *pic = items[idx];
            
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
            [button addTarget:self action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
            
            [button loadBackground:pic.urlSquare];
            [cell addSubview:button];
        }
    }
    return cell;
}


#pragma mark - SSCollectionViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)showPic:(UIButton*)sender {
    [self performSegueWithIdentifier:@"PictureDetail" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        [viewPicDetail setPictureID:sender.tag];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSUInteger)section {
	return 10.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSUInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSUInteger)section {
	return 40.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    [view addSubview:indicator];
    return view;
}


- (void)receiveLoggedIn:(NSNotification *) notification {
    navigationBarPanGestureRecognizer.enabled = true;
    
    buttonLeftMenu.hidden = false;
    buttonNavRight.hidden = true;
}

- (void)receiveLoggedOut:(NSNotification *) notification {
    navigationBarPanGestureRecognizer.enabled = false;
    
    buttonLeftMenu.hidden = true;
    buttonNavRight.hidden = false;
}

- (void)loginPressed:(id)sender {
    [self performSegueWithIdentifier:@"Login" sender:self];
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
            [indicator startAnimating];
            
            [[LatteAPIClient sharedClient] getPath:@"api/picture/latests"
                                              parameters: [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:pagephoto+1]
                                                                                      forKey:@"page"]
                                                 success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                     
                                                     
                                                     pagephoto += 1;
                                                     NSArray *pics = [JSON objectForKey:@"pics"];
                                                     
                                                     if (pics.count > 0) {
                                                         for (NSDictionary *pic in pics) {
                                                             [items addObject:[Picture instanceFromDictionary:pic]];
                                                         }
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
    [super viewDidUnload];
}
@end
