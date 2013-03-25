//
//  LXPicCommentViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXPicCommentViewController.h"

#import "LXCellComment.h"
#import "LXAppDelegate.h"
#import "LXMyPageViewController.h"
//#import "SideSwipeTableViewCell.h"
#import "LXCommentControllViewController.h"
#import "LXButtonBack.h"

@interface LXPicCommentViewController ()

@end

@implementation LXPicCommentViewController {
    UITapGestureRecognizer *gestureTap;
    NSInteger heightHeader;
}

@synthesize viewHeader;
@synthesize growingComment;
@synthesize buttonSend;
@synthesize activityLoad;

- (void)viewDidLoad
{
    growingComment.delegate = self;
    [super viewDidLoad];
        
    gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackground:)];
    
    growingComment.layer.borderWidth = 1;
    growingComment.layer.borderColor = [UIColor grayColor].CGColor;
    growingComment.layer.cornerRadius = 5;
    growingComment.layer.masksToBounds = YES;
    growingComment.internalTextView.keyboardAppearance = UIKeyboardTypeTwitter;
    growingComment.internalTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Component"
                                                             bundle:nil];
    UIViewController *viewCommentControl = [mainStoryboard instantiateViewControllerWithIdentifier:@"Comment"];
    viewCommentControl.view.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.rowHeight);
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (app.currentUser != nil) {
        // Edit Swipe
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedHorizontal)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
        [_tableView addGestureRecognizer:swipe];
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 45, 0);
        _tableView.contentInset = padding;
        _tableView.scrollIndicatorInsets = padding;
    } else {
        viewHeader.hidden = true;
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    UIBarButtonItem *navLeftItem = self.navigationItem.leftBarButtonItem;
    LXButtonBack *buttonBack = (LXButtonBack*)navLeftItem.customView;
    [buttonBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [LXUtils globalShadow:viewHeader];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.tableView addGestureRecognizer:gestureTap];
    
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = viewHeader.frame;
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, keyboardBounds.size.height + 45, 0);
    
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	viewHeader.frame = containerFrame;
    _tableView.contentInset = padding;
    _tableView.scrollIndicatorInsets = padding;
	
	// commit animations
	[UIView commitAnimations];

}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.tableView removeGestureRecognizer:gestureTap];
    
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = viewHeader.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    UIEdgeInsets padding;
    if (app.currentUser != nil) {
        padding = UIEdgeInsetsMake(0, 0, 45, 0);
    } else {
        padding = UIEdgeInsetsMake(0, 0, 0, 0);
    }
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	viewHeader.frame = containerFrame;
    
    _tableView.contentInset = padding;
    _tableView.scrollIndicatorInsets = padding;
	
	// commit animations
	[UIView commitAnimations];
}

- (void)swipedHorizontal {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    buttonSend.enabled = growingTextView.text.length > 0;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = viewHeader.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    viewHeader.frame = r;
}


- (void)setComments:(NSMutableArray *)comments {
    _comments = comments;
    [self.tableView reloadData];
    [activityLoad stopAnimating];
}

- (BOOL)sendComment {
    if (growingComment.text.length < 3000) {
        // Submit comment
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                               [app getToken], @"token",
                               growingComment.text, @"description", nil];
        
        NSString *url = [NSString stringWithFormat:@"picture/%d/comment_post", [_picture.pictureId integerValue]];
        
        [[LatteAPIClient sharedClient] postPath:url
                                     parameters:param
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            Comment *comment = [Comment instanceFromDictionary:[JSON objectForKey:@"comment"]];
                                            [_comments addObject:comment];
                                            NSIndexPath *path = [NSIndexPath indexPathForRow:_comments.count-1 inSection:0];
                                            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationRight];
                                            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            TFLog(@"Something went wrong (Comment)");
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                            message:error.localizedDescription
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                        }];
        
        growingComment.text = @"";
        buttonSend.enabled = false;
        [growingComment resignFirstResponder];
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void)touchBackground:(id)sender {
    [growingComment resignFirstResponder];
}

- (IBAction)touchSend:(id)sender {
    [self sendComment];
}

- (void)showUser:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    Comment *comment = _comments[sender.tag];
    viewUserPage.user = comment.user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Comment* comment = _comments[indexPath.row];
        [_comments removeObject:comment];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        
        NSString *url = [NSString stringWithFormat:@"picture/comment/%d/delete", [comment.commentId integerValue]];
        [[LatteAPIClient sharedClient] postPath:url
                                     parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                        success:nil
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            [_comments insertObject:comment atIndex:indexPath.row];
                                            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                        }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _comments.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LXCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment" forIndexPath:indexPath];
        
    Comment *comment = _comments[indexPath.row];
    
    cellComment.comment = comment;
    
    if (!comment.user.isUnregister) {
        cellComment.buttonUser.tag = indexPath.row;
        cellComment.buttonLike.tag = indexPath.row;
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cellComment;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = _comments[indexPath.row];
    NSString *strComment = comment.descriptionText;
    CGSize labelSize = [strComment sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]
                              constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(labelSize.height + 45, 42);
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    Comment* comment = _comments[indexPath.row];
    return ([comment.user.userId integerValue] == [app.currentUser.userId integerValue]) || _picture.isOwner;
}

@end
