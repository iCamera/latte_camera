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

@interface LXSearchViewController ()

@end

@implementation LXSearchViewController {
    NSMutableArray *pictures;
    NSMutableArray *users;
    NSArray *tags;
    NSInteger page;
    BOOL loadEnded;
    AFHTTPRequestOperation *currentRequest;
}

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
    
    //setup left button
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    [app.tracker set:kGAIScreenName
               value:@"Search Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];

    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"LXCellFriend" bundle:nil] forCellReuseIdentifier:@"User"];
    [self.searchDisplayController.searchResultsTableView registerClass:[LXCellGrid class] forCellReuseIdentifier:@"Grid"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellSearchUser" bundle:nil] forCellReuseIdentifier:@"User"];
    
    [self reloadTags];
}

- (void)reloadTags {
    [activityLoad startAnimating];
    [[LatteAPIClient sharedClient] GET:@"picture/trending/popular"
                                parameters:nil
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       tags = [JSON objectForKey:@"tags"];
                                       [self.tableView reloadData];
                                       [activityLoad stopAnimating];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [activityLoad stopAnimating];
                                   }];
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
            return (pictures.count/3) + (pictures.count%3>0?1:0);
        }
        
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 1) {
            return users.count;
        }
    } else {
        return tags.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
            LXCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:@"Grid" forIndexPath:indexPath];
            cell.viewController = self;
            [cell setPictures:pictures forRow:indexPath.row];
            return cell;
        }

        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 1) {
            LXCellFriend *cell = [tableView dequeueReusableCellWithIdentifier:@"User" forIndexPath:indexPath];
            cell.user = users[indexPath.row];
            return cell;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tags" forIndexPath:indexPath];
        cell.textLabel.text = tags[indexPath.row];
        return cell;
    }
}

- (void)showPic:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery" bundle:nil];
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
            return 104;
        }
        
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 1) {
            return 44;
        }
    } else {
        return 30;
    }
}

#pragma mark - Table view delegate

- (void)loadMore {
    if (self.searchDisplayController.active) {
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
            [self loadPhotoSearch];
        }
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 1) {
            [self loadUserSearch];
        }
    }
}

- (void)loadPhotoSearch {
    NSDictionary *param = @{@"keyword": self.searchDisplayController.searchBar.text,
                            @"page": [NSNumber numberWithInteger:page]};
    
    if (currentRequest && currentRequest.isExecuting)
        [currentRequest cancel];
    currentRequest = [[LatteAPIClient sharedClient] GET:@"picture/tag"
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
                                       
                                       [self.searchDisplayController.searchResultsTableView reloadData];
                                       [activityLoad stopAnimating];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [activityLoad stopAnimating];
                                   }];
}

- (void)loadUserSearch {
    [activityLoad startAnimating];
    
    if (self.searchDisplayController.searchBar.text.length == 0) {
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
                                         
                                         [self.searchDisplayController.searchResultsTableView reloadData];
                                         [activityLoad stopAnimating];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         loadEnded = true;
                                         [activityLoad stopAnimating];
                                     }];
    } else {
        NSString *url = [NSString stringWithFormat:@"user/search"];
        
        NSDictionary *param = @{@"keyword": self.searchDisplayController.searchBar.text,
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
                                         
                                         [self.searchDisplayController.searchResultsTableView reloadData];
                                         [activityLoad stopAnimating];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         loadEnded = true;
                                         [activityLoad stopAnimating];
                                     }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
            
        }
        
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 1) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                                     bundle:nil];
            LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
            viewUserPage.user = users[indexPath.row];
            [self.navigationController pushViewController:viewUserPage animated:YES];

        }
    } else {
        UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        LXTagHome *controllerTag = (LXTagHome*)[mainStory instantiateViewControllerWithIdentifier:@"TagHome"];
        controllerTag.tag = tags[indexPath.row];
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
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    page = 1;
    
    if (controller.searchBar.selectedScopeButtonIndex == 0) {
        [self loadPhotoSearch];
    }
    
    if (controller.searchBar.selectedScopeButtonIndex == 1) {
        [self loadUserSearch];
        
    }
    return NO;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    page = 1;
    if (searchOption == 0) {
        [self loadPhotoSearch];
    }
    
    if (searchOption == 1) {
        [self loadUserSearch];
    }

    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    [self.tableView reloadData];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
