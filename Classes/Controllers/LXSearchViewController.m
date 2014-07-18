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
    NSMutableArray *tags;
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

    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellFriend" bundle:nil] forCellReuseIdentifier:@"User"];
    [self.tableView registerClass:[LXCellGrid class] forCellReuseIdentifier:@"Grid"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellTag" bundle:nil] forCellReuseIdentifier:@"Tag"];
    
    _searchBar.showsCancelButton = NO;
    
    page = 1;
    [self loadPhotoSearch];
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
    if (_searchBar.selectedScopeButtonIndex == 0) {
        return (pictures.count/3) + (pictures.count%3>0?1:0);
    }
    
    if (_searchBar.selectedScopeButtonIndex == 1) {
        return users.count;
    }
    
    if (_searchBar.selectedScopeButtonIndex == 2) {
        return tags.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searchBar.selectedScopeButtonIndex == 0) {
        LXCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:@"Grid" forIndexPath:indexPath];
        cell.viewController = self;
        [cell setPictures:pictures forRow:indexPath.row];
        return cell;
    }
    
    if (_searchBar.selectedScopeButtonIndex == 1) {
        LXCellFriend *cell = [tableView dequeueReusableCellWithIdentifier:@"User" forIndexPath:indexPath];
        cell.user = users[indexPath.row];
        return cell;
    }
    
    if (_searchBar.selectedScopeButtonIndex == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag" forIndexPath:indexPath];
        cell.textLabel.text = tags[indexPath.row][@"term"];
        cell.detailTextLabel.text = [tags[indexPath.row][@"count"] stringValue];
        return cell;
    }
    
    return nil;
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
    if (_searchBar.selectedScopeButtonIndex == 0) {
        return 104;
    }
    
    if (_searchBar.selectedScopeButtonIndex == 1) {
        return 44;
    }
    
    if (_searchBar.selectedScopeButtonIndex == 2) {
        return 44;
    }
    
    return 0;
    
}

#pragma mark - Table view delegate

- (void)loadMore {
    if (_searchBar.selectedScopeButtonIndex == 0) {
        [self loadPhotoSearch];
    }
}

- (void)loadPhotoSearch {
    NSDictionary *param = @{@"keyword": _searchBar.text,
                            @"limit": @"30",
                            @"page": [NSNumber numberWithInteger:page]};
    
    if (currentRequest && currentRequest.isExecuting)
        [currentRequest cancel];
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
    
    if (_searchBar.selectedScopeButtonIndex == 0) {
        
    }
    
    if (_searchBar.selectedScopeButtonIndex == 1) {
        LXUserPageViewController *viewUserPage = [mainStory instantiateViewControllerWithIdentifier:@"UserPage"];
        viewUserPage.user = users[indexPath.row];
        [self.navigationController pushViewController:viewUserPage animated:YES];
        
    }
    
    if (_searchBar.selectedScopeButtonIndex == 2) {
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
    
    if (searchBar.selectedScopeButtonIndex == 0) {
        [self loadPhotoSearch];
    }
    
    if (searchBar.selectedScopeButtonIndex == 1) {
        [self loadUserSearch];
    }
    
    if (searchBar.selectedScopeButtonIndex == 2) {
        [self loadTagSearch];
        
    }
}


- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    page = 1;
    if (selectedScope == 0) {
        [self loadPhotoSearch];
    }
    
    if (selectedScope == 1) {
        [self loadUserSearch];
    }
    
    if (selectedScope == 2) {
        [self loadTagSearch];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
