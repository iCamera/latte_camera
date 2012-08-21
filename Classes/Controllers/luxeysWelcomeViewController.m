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

@interface luxeysWelcomeViewController ()

@property (assign, nonatomic) NSInteger countPic;

@end

@implementation luxeysWelcomeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;
    self.collectionView.rowSpacing = 5;
    self.collectionView.minimumColumnSpacing = 0;
	
//    UIImage *imageButtonNormal = [[UIImage imageNamed:@"bg_bt.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
//    UIImage *imageButtonOn = [[UIImage imageNamed:@"bg_bt_on.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
//    [self.buttonLogin setBackgroundImage:imageButtonNormal forState:UIControlStateNormal];
//    [self.buttonLogin setBackgroundImage:imageButtonOn forState:UIControlStateHighlighted];
    

    [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/latests"
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             NSArray* pics = [JSON objectForKey:@"pics"];
                                             self.countPic = [pics count];
                                             
                                             _items = [NSArray array];
                                             for (NSDictionary* pic in pics) {
                                                 _items = [_items arrayByAddingObject:[pic objectForKey:@"url_square"]];
                                             }
                                             [self.collectionView reloadData];
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                             message:@"Something went wrong (Welcome)"
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles:nil
                                                                   ];
                                             [alert show];
                                         }];
}

#pragma mark - SSCollectionViewDataSource

- (NSUInteger)numberOfSectionsInCollectionView:(SSCollectionView *)aCollectionView {
	return 1;
}


- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
	return self.countPic;
}


- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
	static NSString *const itemIdentifier = @"itemIdentifier";
	
	SCImageCollectionViewItem *item = (SCImageCollectionViewItem *)[aCollectionView dequeueReusableItemWithIdentifier:itemIdentifier];
	if (item == nil) {
		item = [[SCImageCollectionViewItem alloc] initWithReuseIdentifier:itemIdentifier];
	}
	
//	CGFloat size = 80.0f * [[UIScreen mainScreen] scale];
//	NSInteger i = (50 * indexPath.section) + indexPath.row;

	item.imageURL = [NSURL URLWithString:[_items objectAtIndex:indexPath.row]];
	
	return item;
}


//- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
//	SSLabel *header = [[SSLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f)];
//	header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//	header.text = [NSString stringWithFormat:@"Section %i", section + 1];
//	header.textEdgeInsets = UIEdgeInsetsMake(0.0f, 19.0f, 0.0f, 19.0f);
//	header.shadowColor = [UIColor whiteColor];
//	header.shadowOffset = CGSizeMake(0.0f, 1.0f);
//	header.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
//	return header;
//}


#pragma mark - SSCollectionViewDelegate

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
	return CGSizeMake(100.0f, 100.0f);
}


- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSString *title = [NSString stringWithFormat:@"You selected item %i in section %i!",
					   indexPath.row + 1, indexPath.section + 1];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil
										  cancelButtonTitle:@"Oh, awesome!" otherButtonTitles:nil];
	[alert show];
}


- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
	return 40.0f;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setButtonLogin:nil];
    [super viewDidUnload];
}
@end
