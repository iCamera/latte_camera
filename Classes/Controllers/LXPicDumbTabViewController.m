//
//  LXPicDumbTabViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/21/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXPicDumbTabViewController.h"
#import "LXCellTag.h"
#import "LXButtonBack.h"

@interface LXPicDumbTabViewController () {
    NSArray *results;
}

@end

@implementation LXPicDumbTabViewController

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self.tableView setEditing:YES animated:YES];
    
    for (UIView *subView in self.searchDisplayController.searchBar.subviews) {
        //        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
        //            UIButton *cancelButton = (UIButton*)subView;
        //            [cancelButton setTitle:@"OK" forState:UIControlStateNormal];
        //        }
        for (UIView *subSubview in subView.subviews)
        {
            if ([subSubview conformsToProtocol:@protocol(UITextInputTraits)])
            {
                UITextField *textField = (UITextField *)subSubview;
                //                [textField setKeyboardAppearance: UIKeyboardAppearanceAlert];
                textField.returnKeyType = UIReturnKeyDone;
                break;
            }
        }
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
//    [self.searchDisplayController setActive:YES animated:NO];
//    [self.searchDisplayController.searchBar becomeFirstResponder];
}

- (void)keyboardWillAppear:(NSNotification *)notification
{
    //[self.searchDisplayController.searchBar setShowsCancelButton:NO animated:NO];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (![_tags containsObject:results[indexPath.row]]) {
            [_tags addObject:results[indexPath.row]];
        } else {
            [_tags removeObject:results[indexPath.row]];
        }
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return results.count;
    } else {
        return _tags.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Result"];
        cell.textLabel.text = results[indexPath.row];
        if ([_tags containsObject:results[indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag" forIndexPath:indexPath];
        cell.textLabel.text = _tags[indexPath.row];
        
        return cell;
    }
}


// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_tags removeObjectAtIndex:indexPath.row];
		[aTableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark Row reordering
// Determine whether a given row is eligible for reordering or not.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
// Process the row move. This means updating the data model to correct the item indices.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
	  toIndexPath:(NSIndexPath *)toIndexPath {
    if (toIndexPath.row < _tags.count && fromIndexPath.row < _tags.count) {
        NSString *item = [_tags objectAtIndex:fromIndexPath.row];
        [_tags removeObject:item];
        [_tags insertObject:item atIndex:toIndexPath.row];
    }
}

#pragma mark - UISearchDisplayController delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    results = [NSArray arrayWithObject:searchString];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchDisplayController setActive:NO animated:YES];
}

/*
 - (BOOL)searchDisplayController:(UISearchDisplayController *)controller
 shouldReloadTableForSearchScope:(NSInteger)searchOption
 {
 [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
 scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
 objectAtIndex:searchOption]];
 
 return YES;
 }
 
 */


@end
