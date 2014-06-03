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
#import "LXUserPageViewController.h"
#import "LXButtonBack.h"
#import "MBProgressHUD.h"
#import "LXReportAbuseCommentViewController.h"

@interface LXPicCommentViewController ()

@end

@implementation LXPicCommentViewController {
    UITapGestureRecognizer *gestureTap;
    NSInteger heightHeader;
    NSMutableArray *userTag;
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
    
    userTag = [[NSMutableArray alloc] init];
    
    [LXUtils globalShadow:viewHeader];
    
    if (_picture.comments) {
        _comments = _picture.comments;
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_comments.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [activityLoad stopAnimating];
        self.tableView.tableFooterView = nil;
        
    } else {
        NSString *urlDetail = [NSString stringWithFormat:@"picture/%ld", [_picture.pictureId integerValue]];
        [activityLoad startAnimating];
        self.tableView.tableFooterView = _viewFooter;
        [[LatteAPIClient sharedClient] GET:urlDetail parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            _comments = [Comment mutableArrayFromDictionary:JSON withKey:@"comments"];
            [self.tableView reloadData];
            //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_comments.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [activityLoad stopAnimating];
            self.tableView.tableFooterView = nil;
        } failure:nil];
    }
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
    
    // Remove all user tag if empty
    if (growingTextView.text.length == 0) {
        userTag = [[NSMutableArray alloc] init];
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
//    float diff = (growingTextView.frame.size.height - height);
//    
//	CGRect r = viewHeader.frame;
//    r.size.height -= diff;
//    r.origin.y += diff;
//    viewHeader.frame = r;
    _constraintTextHeight.constant = height + 20;
}


- (BOOL)sendComment {
    if (growingComment.text.length < 3000) {
        // Submit comment
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               [app getToken], @"token",
                               growingComment.text, @"description",
                               nil];
        if (userTag.count > 0) {
            NSString* mention = [userTag componentsJoinedByString:@","];
            [param setObject:mention forKey:@"mention"];
        }
        
        NSString *url = [NSString stringWithFormat:@"picture/%d/comment_post", [_picture.pictureId integerValue]];
        
        [MBProgressHUD showHUDAddedTo:self.view.superview.superview.superview animated:YES];
        [growingComment resignFirstResponder];
        
        [[LatteAPIClient sharedClient] POST:url
                                     parameters:param
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            Comment *comment = [Comment instanceFromDictionary:[JSON objectForKey:@"comment"]];
                                            [_comments addObject:comment];
                                            NSIndexPath *path = [NSIndexPath indexPathForRow:_comments.count-1 inSection:0];
                                            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationRight];
                                            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                            growingComment.text = @"";
                                            userTag = [[NSMutableArray alloc] init];
                                            buttonSend.enabled = false;
                                            [MBProgressHUD hideHUDForView:self.view.superview.superview.superview animated:YES];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            DLog(@"Something went wrong (Comment)");
                                            [MBProgressHUD hideHUDForView:self.view.superview.superview.superview animated:YES];
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                            message:error.localizedDescription
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                        }];
        
        
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
    Comment *comment = _comments[sender.tag];
    [_parent showUserFromComment:comment];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Comment* comment = _comments[indexPath.row];
        [_comments removeObject:comment];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        
        NSString *url = [NSString stringWithFormat:@"picture/comment/%d/delete", [comment.commentId integerValue]];
        [[LatteAPIClient sharedClient] POST:url
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
    LXCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
        
    Comment *comment = _comments[indexPath.row];
    
    cellComment.comment = comment;
    
    if (!comment.user.isUnregister) {
        cellComment.buttonUser.tag = indexPath.row;
        cellComment.buttonLike.tag = indexPath.row;
        cellComment.buttonReply.tag = indexPath.row;
        cellComment.buttonReport.tag = indexPath.row;
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        [cellComment.buttonReply addTarget:self action:@selector(touchReply:) forControlEvents:UIControlEventTouchUpInside];
        [cellComment.buttonReport addTarget:self action:@selector(touchReport:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cellComment;
}

- (void)touchReply:(UIButton*)sender {
    Comment *comment = _comments[sender.tag];
    NSString *append = [NSString stringWithFormat:@"> %@: ", comment.user.name];
    growingComment.text = [growingComment.text stringByAppendingString:append];
    if ([userTag indexOfObject:comment.user.userId] == NSNotFound)
        [userTag addObject:comment.user.userId];
    
    [growingComment becomeFirstResponder];
}

- (void)touchReport:(UIButton*)sender {
    Comment *comment = _comments[sender.tag];
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery" bundle:nil];
    LXReportAbuseCommentViewController *controllerReport = [storyGallery instantiateViewControllerWithIdentifier:@"ReportComment"];
    controllerReport.comment = comment;
    [_parent.navigationController pushViewController:controllerReport animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = _comments[indexPath.row];
    NSString *strComment = comment.descriptionText;
    CGSize labelSize = [strComment sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]
                              constrainedToSize:CGSizeMake(266.0f, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 50;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    Comment* comment = _comments[indexPath.row];
    return ([comment.user.userId integerValue] == [app.currentUser.userId integerValue]) || _picture.isOwner;
}

- (void)viewDidUnload {
    [self setViewFooter:nil];
    [super viewDidUnload];
}
@end
