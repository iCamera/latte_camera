//
//  LXSearchViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/8/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXSearchViewController.h"
#import "LXUtils.h"
#import "LXCellGrid.h"
#import "LatteAPIClient.h"
#import "LXAppDelegate.h"
#import "LXButtonBack.h"
#import "LXCellSearchUser.h"
#import "Picture.h"

typedef enum {
    kSearchPhoto,
    kSearchFriend,
} SearchMode;

@interface LXSearchViewController ()

@end

@implementation LXSearchViewController {
    NSMutableArray *pictures;
    NSMutableArray *users;
    SearchMode tableMode;
}

@synthesize viewSearchBox;
@synthesize textKeyword;
@synthesize buttonSearchPeople;
@synthesize buttonSearchPhoto;
@synthesize activityLoad;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    textKeyword.layer.borderWidth = 1;
    textKeyword.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textKeyword.layer.cornerRadius = 5;
    
    UIImageView *imageSearch = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    imageSearch.contentMode = UIViewContentModeCenter;
    imageSearch.image = [UIImage imageNamed:@"icon_search_m.png"];
    textKeyword.leftView = imageSearch;
    textKeyword.leftViewMode = UITextFieldViewModeAlways;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    [LXUtils globalShadow:viewSearchBox];
    
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:viewSearchBox.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){5.0, 5.0}].CGPath;
    viewSearchBox.layer.mask = maskLayer;
    //viewSearchBox.layer.cornerRadius = 5.0;
    
    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackground:)];
    [self.tableView addGestureRecognizer:gestureTap];
    tableMode = kSearchPhoto;
    
    UIBarButtonItem *navLeftItem = self.navigationItem.leftBarButtonItem;
    LXButtonBack *buttonBack = (LXButtonBack*)navLeftItem.customView;
    [buttonBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)touchBackground:(id)sender {
    [textKeyword resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableMode == kSearchPhoto) {
        return (pictures.count/3) + (pictures.count%3>0?1:0);
    } else {
        NSInteger ret = users.count;
        LXAppDelegate* app = [LXAppDelegate currentDelegate];
        if (app.currentUser != nil) {
            if (users.count == 0) {
                ret += 1;
            }
        }
        return ret;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableMode == kSearchPhoto) {
        static NSString *CellIdentifier = @"Grid";
        LXCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.viewController = self;
        [cell setPictures:pictures forRow:indexPath.row];
        return cell;
    } else {
        if (users.count == 0) {
            return [tableView dequeueReusableCellWithIdentifier:@"FacebookSearch" forIndexPath:indexPath];
        } else {
            LXCellSearchUser *cell = [tableView dequeueReusableCellWithIdentifier:@"User" forIndexPath:indexPath];
            cell.parentNav = self.navigationController;
            cell.user = users[indexPath.row];
            return cell;
        }
        
    }
}

- (void)showPic:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    
    viewGallery.picture = pictures[sender.tag];
    
    [self presentViewController:navGalerry animated:YES completion:nil];
}

- (NSDictionary *)pictureAfterPicture:(Picture *)picture {
    NSUInteger current = [pictures indexOfObject:picture];
    if (current == pictures.count-1) {
        return nil;
    }
    Picture *picNext = pictures[current+1];
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         picNext, @"picture",
                         nil];
    return ret;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {
    NSUInteger current = [pictures indexOfObject:picture];
    if (current == 0) {
        return nil;
    }
    Picture *picPrev = pictures[current-1];
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         picPrev, @"picture",
                         nil];
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kSearchPhoto) {
        return 104;
    } else {
        if (users.count == 0) {
            return 40;
        } else {
            return 79;
        }
    }
}

#pragma mark - Table view delegate

- (IBAction)touchTab:(UIButton *)sender {
    buttonSearchPhoto.enabled = true;
    buttonSearchPeople.enabled = true;
    
    sender.enabled = false;
    textKeyword.text = @"";
    
    switch (sender.tag) {
        case 1:
            tableMode = kSearchPhoto;
            break;
        case 2:
            tableMode = kSearchFriend;
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}

- (IBAction)textChanged:(id)sender {
    if (textKeyword.text.length > 2) {
        [activityLoad startAnimating];
        
        if (tableMode == kSearchPhoto) {
        NSString *url = [NSString stringWithFormat:@"picture/tag/%@", textKeyword.text];
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                               [app getToken], @"token", nil];
        
        [[LatteAPIClient sharedClient] getPath:url
                                     parameters:param
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            pictures = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                            [self.tableView reloadData];
                                            [activityLoad stopAnimating];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            TFLog(@"Something went wrong Tag");
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                            message:error.localizedDescription
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                            [activityLoad stopAnimating];
                                        }];
        } else if (tableMode == kSearchFriend) {
            NSString *url = [NSString stringWithFormat:@"user/search"];
            LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
            NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [app getToken], @"token",
                                   textKeyword.text, @"nick", nil];
            
            [[LatteAPIClient sharedClient] getPath:url
                                        parameters:param
                                           success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                               users = [User mutableArrayFromDictionary:JSON withKey:@"users"];
                                               [self.tableView reloadData];
                                               [activityLoad stopAnimating];
                                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               TFLog(@"Something went wrong Tag");
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                               message:error.localizedDescription
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                     otherButtonTitles:nil];
                                               [alert show];
                                               [activityLoad stopAnimating];
                                           }];
        }
    }
}

@end
