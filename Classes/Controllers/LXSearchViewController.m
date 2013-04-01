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
#import "LXCellTags.h"
#import "Picture.h"
#import "LXCellSearchConnection.h"
#import "LXTagViewController.h"

typedef enum {
    kSearchPhoto,
    kSearchFriend,
} SearchMode;

@interface LXSearchViewController ()

@end

@implementation LXSearchViewController {
    NSMutableArray *pictures;
    NSMutableArray *users;
    NSArray *tags;
    SearchMode tableMode;
}

@synthesize textKeyword;
@synthesize buttonSearchPeople;
@synthesize buttonSearchPhoto;
@synthesize activityLoad;
@synthesize buttonSearch;

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

    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackground:)];
    [self.tableView addGestureRecognizer:gestureTap];
    tableMode = kSearchPhoto;
    
    //setup left button
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    UIBarButtonItem *navLeftItem = self.navigationItem.leftBarButtonItem;
    UIButton *buttonSide = (UIButton*)navLeftItem.customView;
    [buttonSide addTarget:app.controllerSide action:@selector(toggleLeftPanel:) forControlEvents:UIControlEventTouchUpInside];
    
    [app.tracker sendView:@"Search Screen"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadTags];
    [super viewWillAppear:animated];
}

- (void)reloadTags {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           textKeyword.text, @"keyword", nil];
    [[LatteAPIClient sharedClient] getPath:@"picture/trending"
                                parameters:param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       tags = [JSON objectForKey:@"tags"];
                                       [self.tableView reloadData];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong Tag");
                                   }];
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
        if (pictures.count > 0)
            return (pictures.count/3) + (pictures.count%3>0?1:0);
        else
            return tags.count;
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
        if (pictures.count > 0) {
            static NSString *CellIdentifier = @"Grid";
            LXCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            cell.viewController = self;
            [cell setPictures:pictures forRow:indexPath.row];
            return cell;
        } else {
            static NSString *CellIdentifier = @"Tags";
            LXCellTags *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            [cell.buttonTag setTitle:tags[indexPath.row] forState:UIControlStateNormal];
            [cell.buttonTag addTarget:self action:@selector(showTag:) forControlEvents:UIControlEventTouchUpInside];
            cell.buttonTag.tag = indexPath.row;
            return cell;
        }
    } else {
        if (users.count == 0) {
            LXCellSearchConnection *cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookSearch" forIndexPath:indexPath];
            cell.controller = self;
            return cell;
        } else {
            LXCellSearchUser *cell = [tableView dequeueReusableCellWithIdentifier:@"User" forIndexPath:indexPath];
            cell.parentNav = self.navigationController;
            cell.user = users[indexPath.row];
            return cell;
        }
        
    }
}

- (void)showTag:(UIButton*)sender {
    [self performSegueWithIdentifier:@"ShowTag" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton*)sender {
    if ([segue.identifier isEqualToString:@"ShowTag"]) {
        LXTagViewController *controllerTag = (LXTagViewController*)segue.destinationViewController;
        controllerTag.keyword = tags[sender.tag];
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
    if (current == NSNotFound || current == pictures.count-1) {
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
    if (current == NSNotFound || current == 0) {
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
        if (pictures.count > 0) {
            return 104;
        } else {
            return 36;
        }
        
    } else {
        if (users.count == 0) {
            return 86;
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
    [textKeyword resignFirstResponder];
    [activityLoad startAnimating];
    
    if (tableMode == kSearchPhoto) {
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                               [app getToken], @"token",
                               textKeyword.text, @"keyword", nil];
        
        [[LatteAPIClient sharedClient] getPath:@"picture/tag"
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

- (IBAction)editChanged:(id)sender {
    buttonSearch.enabled = textKeyword.text.length > 0;
}
@end
