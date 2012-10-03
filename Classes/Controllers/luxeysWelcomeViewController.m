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
@synthesize navigationBarPanGestureRecognizer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedIn:)
                                                 name:@"LoggedIn"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedOut:)
                                                 name:@"LoggedOut"
                                               object:nil];
    
    loadEnded = false;
    pagephoto = 1;
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidesWhenStopped = true;
    [indicator setCenter:CGPointMake(160, 20)];
    
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    collectionView = [[SSCollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44)];
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;
    collectionView.rowSpacing = 5;
    collectionView.minimumColumnSpacing = 0;
    collectionView.scrollView.delegate = self;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 50, 0.0);
    
    collectionView.scrollView.contentInset = contentInsets;
    collectionView.scrollView.scrollIndicatorInsets = contentInsets;
    
    [self.view addSubview:collectionView];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/latests"
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             _items = [[NSMutableArray alloc] init];
                                             for (NSDictionary *pic in [JSON objectForKey:@"pics"]) {
                                                 [_items addObject:[LuxeysPicture instanceFromDictionary:pic]];
                                             }
                                             [collectionView reloadData];

                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });

                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });

                                             NSLog(@"Something went wrong (Welcome)");
                                         }];
    });
    
    [self.buttonNavRight addTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - SSCollectionViewDataSource

- (NSUInteger)numberOfSectionsInCollectionView:(SSCollectionView *)aCollectionView {
	return 1;
}


- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
	return [_items count];
}


- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
	static NSString *const itemIdentifier = @"itemIdentifier";
	
	SCImageCollectionViewItem *item = (SCImageCollectionViewItem *)[aCollectionView dequeueReusableItemWithIdentifier:itemIdentifier];
	if (item == nil) {
		item = [[SCImageCollectionViewItem alloc] initWithReuseIdentifier:itemIdentifier];
	}
	
    
    LuxeysPicture *pic = [_items objectAtIndex:indexPath.row];
    
	item.imageURL = [NSURL URLWithString:pic.urlSquare];
	
	return item;
}



#pragma mark - SSCollectionViewDelegate

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
	return CGSizeMake(100.0f, 100.0f);
}


- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LuxeysPicture *pic = [_items objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"PictureDetail" sender:pic];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(LuxeysPicture *)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        [viewPicDetail setPictureID:[sender.pictureId integerValue]];
    }
}

- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
	return 5.0f;
}

- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForFooterInSection:(NSUInteger)section {
	return 40.0f;
}


- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForFooterInSection:(NSUInteger)section {
    UIView *view = [[UIView alloc] init];
    [view addSubview:indicator];
    return view;
}


- (void)receiveLoggedIn:(NSNotification *) notification {
    // Init side bar
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.storyMain action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    
    [self.buttonLeftMenu addTarget:app.storyMain action:@selector(revealLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonLeftMenu setHidden:NO];
    [self.buttonNavRight removeTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonNavRight addTarget:app.storyMain action:@selector(revealRight:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Style
    UIImage* imageNotify = [UIImage imageNamed:@"icon_info.png"];
    [self.buttonNavRight setImage:imageNotify forState:UIControlStateNormal];
    [self.buttonNavRight setImage:imageNotify forState:UIControlStateHighlighted];
}

- (void)receiveLoggedOut:(NSNotification *) notification {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [self.navigationController.navigationBar removeGestureRecognizer:navigationBarPanGestureRecognizer];
    [self.buttonNavRight removeTarget:app.storyMain action:@selector(revealRight:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonNavRight addTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Style
    UIImage* imageNotify = [UIImage imageNamed:@"icon_login.png"];
    [self.buttonNavRight setImage:imageNotify forState:UIControlStateNormal];
    [self.buttonNavRight setImage:imageNotify forState:UIControlStateHighlighted];
}

- (void)loginPressed:(id)sender {
    [self performSegueWithIdentifier:@"Login" sender:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
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
            
            [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/latests"
                                              parameters: [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:pagephoto+1]
                                                                                      forKey:@"page"]
                                                 success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                     
                                                     
                                                     pagephoto += 1;
                                                     NSArray *pics = [JSON objectForKey:@"pics"];
                                                     
                                                     if (pics.count > 0) {
                                                         for (NSDictionary *pic in pics) {
                                                             [_items addObject:[LuxeysPicture instanceFromDictionary:pic]];
                                                         }
                                                         [collectionView reloadData];
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setButtonLeftMenu:nil];
    [self setButtonNavRight:nil];
    [super viewDidUnload];
}
@end
