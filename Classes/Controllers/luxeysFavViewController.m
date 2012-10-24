//
//  luxeysFavViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/11.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysFavViewController.h"

@interface luxeysFavViewController ()

@end

@implementation luxeysFavViewController

@synthesize buttonNavRight;

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
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.collectionView.bounds.size.height, self.view.frame.size.width, self.collectionView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.collectionView addSubview:refreshHeaderView];

    //Init sidebar
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.revealController action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    [buttonNavRight addTarget:app.revealController action:@selector(revealRight:) forControlEvents:UIControlEventTouchUpInside];

    [self reloadFav];
}

- (void)reloadFav {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
        [[LatteAPIClient sharedClient] getPath:@"api/picture/user/me/voted"
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [app getToken], @"token", nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 pics = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                                 [self.collectionView reloadData];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                                 
                                                 [self doneLoadingTableViewData];
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Something went wrong (Fav)");
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                                 
                                                 [self doneLoadingTableViewData];
                                             }];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return pics.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    luxeysCollectionCellPic *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Picture" forIndexPath:indexPath];
    if (nil == cell) {
        cell = [[luxeysCollectionCellPic alloc] init];
    }
    Picture *pic = pics[indexPath.row];
    cell.buttonPic.tag = [pic.pictureId integerValue];
    [cell.buttonPic loadBackground:pic.urlSquare];
    [cell.buttonPic addTarget:self action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
    [cell setPic:pic];
    return cell;
}

- (void)showPic:(UIButton *)button {
    [self performSegueWithIdentifier:@"PictureDetail" sender:button];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController *view = segue.destinationViewController;
        [view setPictureID:sender.tag];
    }

}


- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    
    [self reloadFav];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


- (IBAction)touchNotify:(id)sender {
}
@end
