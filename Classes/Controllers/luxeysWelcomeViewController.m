//
//  luxeysWelcomeViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/8/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysWelcomeViewController.h"
#import "luxeysLatteAPIClient.h"
#import "SCImageCollectionViewItem.h"
#import "luxeysPicDetailViewController.h"
#import "luxeysAppDelegate.h"

@interface luxeysWelcomeViewController ()

@end

@implementation luxeysWelcomeViewController

@synthesize buttonLeftMenu;
@synthesize buttonNavRight;
@synthesize navigationBarPanGestureRecognizer;
@synthesize collectionView = _collectionView;

BOOL loadingphoto = FALSE;
int pagephoto = 1;

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
    
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    _collectionView = [[SSCollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;
    _collectionView.rowSpacing = 5;
    _collectionView.minimumColumnSpacing = 0;
    _collectionView.scrollView.delegate = self;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 50, 0.0);
    
    _collectionView.scrollView.contentInset = contentInsets;
    _collectionView.scrollView.scrollIndicatorInsets = contentInsets;

    [self.view addSubview:_collectionView];
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/latests"
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             _items = [[NSMutableArray alloc] init];
                                             [_items addObjectsFromArray:[JSON objectForKey:@"pics"]];
                                             
                                             [self.collectionView reloadData];
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Welcome)");
                                         }];
    
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
	

    NSDictionary* pic = [_items objectAtIndex:indexPath.row];

	item.imageURL = [NSURL URLWithString:[pic objectForKey:@"url_square"]];
	
	return item;
}



#pragma mark - SSCollectionViewDelegate

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
	return CGSizeMake(100.0f, 100.0f);
}


- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"PictureDetail" sender:[_items objectAtIndex:indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        viewPicDetail.picInfo = sender;
    }
}

- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
	return 5.0f;
}

- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
    return [[UIView alloc] init];
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
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 10;
    if(y > h + reload_distance) {
        if (!loadingphoto) {
            loadingphoto = TRUE;
            
            [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/latests"
                                              parameters: [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:pagephoto+1]
                                                                                      forKey:@"page"]
                                                 success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                     //[_collectionView beginUpdates];
                                                     
                                                     pagephoto += 1;
                                                     loadingphoto = FALSE;
                                                     
                                                     [_items addObjectsFromArray:[JSON objectForKey:@"pics"]];
                                                      
                                                     [_collectionView reloadData];
                                                     
                                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     NSLog(@"Something went wrong (Welcome)");
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
