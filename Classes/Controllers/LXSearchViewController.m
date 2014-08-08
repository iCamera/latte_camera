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
#import "LatteAPIv2Client.h"
#import "LXAppDelegate.h"
#import "LXButtonBack.h"
#import "LXCellFriend.h"
#import "LXCellTags.h"
#import "Picture.h"
#import "LXCellSearchConnection.h"
#import "LXTagHome.h"
#import "LXUserPageViewController.h"

#import "REFrostedViewController.h"

#import "LXNotificationBar.h"

@interface LXSearchViewController ()

@end

@implementation LXSearchViewController {
    NSMutableArray *pictures;
    NSMutableArray *users;
    NSMutableArray *tags;
    NSInteger page;
    BOOL loadEnded;
    AFHTTPRequestOperation *currentRequest;
}

@synthesize activityLoad;
@synthesize searchView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup left button
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    [app.tracker set:kGAIScreenName
               value:@"Search Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];

    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellFriend" bundle:nil] forCellReuseIdentifier:@"User"];
    [self.tableView registerClass:[LXCellGrid class] forCellReuseIdentifier:@"Grid"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellTag" bundle:nil] forCellReuseIdentifier:@"Tag"];
    
    //[_searchBar becomeFirstResponder];
    
    page = 1;
    searchView = kSearchTag;
    [self loadTagSearch];
    
    LXNotificationBar *viewNotification = [[LXNotificationBar alloc] initWithFrame:CGRectMake(0, 0, 70, 33)];
    viewNotification.parent = self;
    UIBarButtonItem *rightNav = [[UIBarButtonItem alloc] initWithCustomView:viewNotification];
    self.navigationItem.rightBarButtonItem = rightNav;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searchView == kSearchPhoto) {
        return (pictures.count/3) + (pictures.count%3>0?1:0);
    }
    
    if (searchView == kSearchUser) {
        return users.count;
    }
    
    if (searchView == kSearchTag) {
        return tags.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchView == kSearchPhoto) {
        LXCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:@"Grid" forIndexPath:indexPath];
        cell.viewController = self;
        [cell setPictures:pictures forRow:indexPath.row];
        return cell;
    }
    
    if (searchView == kSearchUser) {
        LXCellFriend *cell = [tableView dequeueReusableCellWithIdentifier:@"User" forIndexPath:indexPath];
        cell.user = users[indexPath.row];
        return cell;
    }
    
    if (searchView == kSearchTag) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag" forIndexPath:indexPath];
        cell.textLabel.text = tags[indexPath.row][@"term"];
        cell.detailTextLabel.text = [tags[indexPath.row][@"count"] stringValue];
        cell.imageView.image = nil;
        return cell;
    }
    
    return nil;
}

- (void)showPic:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery" bundle:nil];
    LXGalleryViewController *viewGallery = [storyGallery instantiateInitialViewController];
    viewGallery.delegate = self;
    
    viewGallery.picture = pictures[sender.tag];
    
    [self.navigationController pushViewController:viewGallery animated:YES];
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
    
    if (current > pictures.count - 6) {
        if (!activityLoad.isAnimating && !loadEnded) {
            [self loadMore];
        }
    }
    
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
    if (searchView == kSearchPhoto) {
        return 104;
    }
    
    if (searchView == kSearchUser) {
        return 44;
    }
    
    if (searchView == kSearchTag) {
        return 44;
    }
    
    return 0;
    
}

#pragma mark - Table view delegate

- (void)loadMore {
    if (searchView == kSearchPhoto) {
        [self loadPhotoSearch];
    }
}

- (void)loadPhotoSearch {
    NSDictionary *param = @{@"keyword": _searchBar.text,
                            @"limit": @"30",
                            @"page": [NSNumber numberWithInteger:page]};
    
    if (currentRequest && currentRequest.isExecuting)
        [currentRequest cancel];
    [activityLoad startAnimating];
    currentRequest = [[LatteAPIv2Client sharedClient] GET:@"picture"
                                parameters:param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       NSMutableArray *data = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                       if (page == 1) {
                                           pictures = data;
                                       } else {
                                           [pictures addObjectsFromArray:data];
                                       }
                                       
                                       page += 1;
                                       loadEnded = data.count == 0;
                                       searchView = kSearchPhoto;
                                       
                                       [self.tableView reloadData];
                                       [activityLoad stopAnimating];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [activityLoad stopAnimating];
                                   }];
}

- (void)loadUserSearch {
    [activityLoad startAnimating];
    
    if (_searchBar.text.length == 0) {
        NSString *url = [NSString stringWithFormat:@"user/popular"];
        
        NSDictionary *param = @{@"limit": [NSNumber numberWithInteger:20],
                                @"page": [NSNumber numberWithInteger:page]};
        
        if (currentRequest && currentRequest.isExecuting)
            [currentRequest cancel];
        currentRequest = [[LatteAPIv2Client sharedClient] GET:url
                                  parameters:param
                                     success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                         users = [User mutableArrayFromDictionary:JSON withKey:@"profiles"];
                                         loadEnded = users.count >= [JSON[@"total"] integerValue];
                                         page += 1;
                                         searchView = kSearchUser;
                                         [self.tableView reloadData];
                                         [activityLoad stopAnimating];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         loadEnded = true;
                                         [activityLoad stopAnimating];
                                     }];
    } else {
        NSString *url = [NSString stringWithFormat:@"user/search"];
        
        NSDictionary *param = @{@"keyword": _searchBar.text,
                                @"page": [NSNumber numberWithInteger:page]};
        
        if (currentRequest && currentRequest.isExecuting)
            [currentRequest cancel];
        currentRequest = [[LatteAPIv2Client sharedClient] GET:url
                                  parameters:param
                                     success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                         NSMutableArray *data = [User mutableArrayFromDictionary:JSON withKey:@"profiles"];
                                         if (page == 1) {
                                             users = data;
                                         } else {
                                             [users addObjectsFromArray:data];
                                         }
                                         
                                         page += 1;
                                         loadEnded = users.count >= [JSON[@"total"] integerValue];
                                         searchView = kSearchUser;
                                         [self.tableView reloadData];
                                         [activityLoad stopAnimating];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         loadEnded = true;
                                         [activityLoad stopAnimating];
                                     }];
    }
}

- (void)loadTagSearch {
    [activityLoad startAnimating];
    if (currentRequest && currentRequest.isExecuting)
        [currentRequest cancel];
    
    if (_searchBar.text.length == 0) {
        
        currentRequest = [[LatteAPIv2Client sharedClient] GET:@"picture/get_tag_cloud"
                                                   parameters:@{@"type": @"popular"}
                                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                        tags = [JSON objectForKey:@"tags"];
                                                        searchView = kSearchTag;
                                                        [self.tableView reloadData];
                                                        [activityLoad stopAnimating];
                                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                        [activityLoad stopAnimating];
                                                    }];
    } else {
        currentRequest = [[LatteAPIv2Client sharedClient] GET:@"tag/search" parameters:@{@"keyword": _searchBar.text, @"app": @"true"} success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            tags = [[NSMutableArray alloc] init];
            for (NSDictionary *tag in JSON[@"tags"]) {
                [tags addObject:@{@"term": tag[@"label"], @"count": tag[@"picture_count"]}];
            }
            
            loadEnded = YES;
            searchView = kSearchTag;
            [self.tableView reloadData];
            [activityLoad stopAnimating];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.tableView reloadData];
            loadEnded = true;
            [activityLoad stopAnimating];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    if (searchView == kSearchPhoto) {
        
    }
    
    if (searchView == kSearchUser) {
        LXUserPageViewController *viewUserPage = [mainStory instantiateViewControllerWithIdentifier:@"UserPage"];
        viewUserPage.user = users[indexPath.row];
        [self.navigationController pushViewController:viewUserPage animated:YES];
        
    }
    
    if (searchView == kSearchTag) {
        [_searchBar resignFirstResponder];
        LXTagHome *controllerTag = (LXTagHome*)[mainStory instantiateViewControllerWithIdentifier:@"TagHome"];
        controllerTag.tag = tags[indexPath.row][@"term"];
        [self.navigationController pushViewController:controllerTag animated:YES];
        
    }
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
        if (!activityLoad.isAnimating) {
            [self loadMore];
        }
    }
}

#pragma mark - UISearchDisplayController delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    page = 1;
    
    if (searchView == kSearchPhoto) {
        [self loadPhotoSearch];
    }
    
    if (searchView == kSearchUser) {
        [self loadUserSearch];
    }
    
    if (searchView == kSearchTag) {
        [self loadTagSearch];
        
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (IBAction)switchTab:(UIButton *)sender {
    page = 1;
    _buttonPhoto.selected = NO;
    _buttonUser.selected = NO;
    _buttonTag.selected = NO;
    
    sender.selected = YES;
    
    if (sender.tag == 0) {
        [self loadPhotoSearch];
    }
    
    if (sender.tag == 1) {
        [self loadUserSearch];
    }
    
    if (sender.tag == 2) {
        [self loadTagSearch];
    }
}

- (IBAction)showMenu:(id)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];

}

@end
