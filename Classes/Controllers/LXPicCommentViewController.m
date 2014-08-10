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
#import "MZFormSheetController.h"
#import "LatteAPIv2Client.h"
#import "UIImageView+AFNetworking.h"

@interface LXPicCommentViewController ()

@end

@implementation LXPicCommentViewController {
    NSMutableArray *comments;
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
    [_imageHead setImageWithURL:[NSURL URLWithString:_picture.urlMedium]];
}

- (void)setPicture:(Picture *)picture {
    _picture = picture;
    
    if (_picture.comments) {
        comments = _picture.comments;
        [self.tableView reloadData];
        [activityLoad stopAnimating];
        self.tableView.tableFooterView = nil;
        
    } else {
        [self loadComment];
    }
}

- (void)loadComment {
    NSString *urlDetail = [NSString stringWithFormat:@"picture/%ld", [_picture.pictureId longValue]];
    [activityLoad startAnimating];
    self.tableView.tableFooterView = _viewFooter;
    [[LatteAPIClient sharedClient] GET:urlDetail parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        _picture = [Picture instanceFromDictionary:JSON[@"picture"]];
        [_imageHead setImageWithURL:[NSURL URLWithString:_picture.urlMedium]];
        comments = [Comment mutableArrayFromDictionary:JSON withKey:@"comments"];
        [self.tableView reloadData];
        [self scrollToComment];
        [activityLoad stopAnimating];
        self.tableView.tableFooterView = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [activityLoad stopAnimating];
    }];
    
}

- (void)scrollToComment {
    if (_commentId != 0) {
        NSInteger idx = 0;
        for (NSInteger i = 0; i < comments.count; i++) {
            Comment *comment = _picture.comments[i];
            
            if ([comment.commentId integerValue] == _commentId) {
                idx = i;
                break;
            }
        }
        if (idx > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    } else if (comments.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(comments.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self scrollToComment];
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
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, keyboardBounds.size.height + 45, 0);
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	_constraintInputPadding.constant = keyboardBounds.size.height;
    [self.view layoutIfNeeded];
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
	_constraintInputPadding.constant = 0;
    [self.view layoutIfNeeded];
    
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
        
        NSString *url = [NSString stringWithFormat:@"picture/%ld/comment_post", [_picture.pictureId longValue]];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [growingComment resignFirstResponder];
        
        [[LatteAPIClient sharedClient] POST:url
                                     parameters:param
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            Comment *comment = [Comment instanceFromDictionary:[JSON objectForKey:@"comment"]];
                                            [comments addObject:comment];
                                            NSIndexPath *path = [NSIndexPath indexPathForRow:comments.count-1 inSection:0];
                                            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationRight];
                                            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                            growingComment.text = @"";
                                            userTag = [[NSMutableArray alloc] init];
                                            buttonSend.enabled = false;
                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            DLog(@"Something went wrong (Comment)");
                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    Comment *comment = comments[sender.tag];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = comment.user;
    if (_isModal) {
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            [_parent.navigationController pushViewController:viewUserPage animated:YES];
        }];
    } else {
        [self.navigationController pushViewController:viewUserPage animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Comment* comment = comments[indexPath.row];
        [comments removeObject:comment];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        
        NSString *url = [NSString stringWithFormat:@"picture/comment/%ld/delete", [comment.commentId longValue]];
        [[LatteAPIClient sharedClient] POST:url
                                     parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                        success:nil
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            [comments insertObject:comment atIndex:indexPath.row];
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
    return comments.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        
    Comment *comment = comments[indexPath.row];
    if (comment.commentBlocked) {
        return [tableView dequeueReusableCellWithIdentifier:@"Blocked" forIndexPath:indexPath];;
    } else {
        LXCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment" forIndexPath:indexPath];
        cellComment.parent = self;
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
}

- (void)touchReply:(UIButton*)sender {
    Comment *comment = comments[sender.tag];
    NSString *append = [NSString stringWithFormat:@"> %@: ", comment.user.name];
    growingComment.text = [growingComment.text stringByAppendingString:append];
    if ([userTag indexOfObject:comment.user.userId] == NSNotFound)
        [userTag addObject:comment.user.userId];
    
    [growingComment becomeFirstResponder];
}

- (void)touchReport:(UIButton*)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                               destructiveButtonTitle:NSLocalizedString(@"Block User", @"")
                                                    otherButtonTitles:NSLocalizedString(@"report", @""), nil];
    actionSheet.tag = sender.tag;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    Comment *comment = comments[actionSheet.tag];
    if (buttonIndex == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"Are you sure you want to block this user?", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"Block User", @""), nil];
        alert.tag = actionSheet.tag;
        [alert show];
    }
    
    if (buttonIndex == 1) {
        UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery" bundle:nil];
        LXReportAbuseCommentViewController *controllerReport = [storyGallery instantiateViewControllerWithIdentifier:@"ReportComment"];
        controllerReport.comment = comment;
        
        if (_isModal) {
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                [_parent.navigationController pushViewController:controllerReport animated:YES];
            }];
        } else {
            [self.navigationController pushViewController:controllerReport animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    Comment *comment = comments[alertView.tag];
    if (buttonIndex == 1) {
        NSString *url = [NSString stringWithFormat:@"user/%ld/block", [comment.user.userId longValue]];
        [[LatteAPIv2Client sharedClient] POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            [self loadComment];
        } failure:nil];
    }

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = comments[indexPath.row];
    if (comment.commentBlocked) {
        return 44;
    } else {
        NSString *strComment = comment.descriptionText;
        
        CGRect labelRect = [strComment boundingRectWithSize:CGSizeMake(261.0f, MAXFLOAT)
                                                    options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                 attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13] }
                                                    context:nil];
        return labelRect.size.height + 49;
    }
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    Comment* comment = comments[indexPath.row];
    return ([comment.user.userId integerValue] == [app.currentUser.userId integerValue]) || _picture.isOwner;
}


- (void)viewDidUnload {
    [self setViewFooter:nil];
    [super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden {
    return _isModal;
}
@end
