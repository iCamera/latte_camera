//
//  LXFollowingTagTVC.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/10/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXFollowingTagTVC.h"
#import "LatteAPIv2Client.h"
#import "LXTagHome.h"

@interface LXFollowingTagTVC ()

@end

@implementation LXFollowingTagTVC {
    NSMutableArray *tags;
    NSMutableArray *results;
    AFHTTPRequestOperation *currentRequest;
}

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellTag" bundle:nil] forCellReuseIdentifier:@"Tag"];
    
    LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
    
    [_activityLoad startAnimating];
    [api2 GET:@"tag/following" parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        tags = JSON[@"tags"];
        [self.tableView reloadData];
        [_activityLoad stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_activityLoad stopAnimating];
    }];
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
    if (_searchBar.text.length > 0) {
        return results.count;
    } else {
        return tags.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searchBar.text.length > 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag" forIndexPath:indexPath];
        cell.textLabel.text = results[indexPath.row][@"term"];
        cell.detailTextLabel.text = [results[indexPath.row][@"count"] stringValue];
        cell.imageView.highlighted = [tags containsObject:results[indexPath.row][@"term"]];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag" forIndexPath:indexPath];
        
        cell.textLabel.text = tags[indexPath.row];
        cell.detailTextLabel.text = @"";
        cell.imageView.highlighted = YES;
        
        return cell;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
        [api2 POST:@"tag/unfollow" parameters:@{@"tag": tags[indexPath.row]} success:nil failure:nil];
        
        [tags removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_searchBar resignFirstResponder];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXTagHome *viewTag = [mainStoryboard instantiateViewControllerWithIdentifier:@"TagHome"];
    if (_searchBar.text.length > 0) {
        viewTag.tag = results[indexPath.row][@"term"];
    } else {
        viewTag.tag = tags[indexPath.row];
    }
    
    [self.navigationController pushViewController:viewTag animated:YES];
}


- (void)loadTagSearch {
    [_activityLoad startAnimating];
    if (currentRequest && currentRequest.isExecuting)
        [currentRequest cancel];
    
    currentRequest = [[LatteAPIv2Client sharedClient] GET:@"tag/search" parameters:@{@"keyword": _searchBar.text, @"app": @"true"} success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        results = [[NSMutableArray alloc] init];
        for (NSDictionary *tag in JSON[@"tags"]) {
            [results addObject:@{@"term": tag[@"label"], @"count": tag[@"picture_count"]}];
        }
        
        [self.tableView reloadData];
        [_activityLoad stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_activityLoad stopAnimating];
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        [self loadTagSearch];
        self.navigationItem.rightBarButtonItem = nil;
        [self.tableView setEditing:NO animated:NO];
    } else {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        [self.tableView reloadData];
    }

}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
