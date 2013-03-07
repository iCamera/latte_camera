//
//  LXPicDetailViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXPicDetailViewController.h"

#import "LXMyPageViewController.h"

@interface LXPicDetailViewController ()
@end

@implementation LXPicDetailViewController {
    EGORefreshTableHeaderView *refreshHeaderView;
    Picture *pic;
    User *user;
    BOOL reloading;
    BOOL loaded;
    NSMutableArray *comments;
    NSMutableArray *voters;
    MBProgressHUD *HUD;
}

@synthesize gestureTap;

@synthesize buttonEdit;
@synthesize pic;
@synthesize labelDate;
@synthesize imagePic;
@synthesize labelAccess;
@synthesize labelAuthor;
@synthesize buttonLike;
@synthesize buttonUser;
@synthesize buttonInfo;
@synthesize buttonMap;
@synthesize viewSubPic;
@synthesize indicatorComment;
@synthesize scrollVotes;
@synthesize labelDesc;
@synthesize viewComment;
@synthesize growingComment;
@synthesize buttonSend;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        loaded = FALSE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Picture Detail Screen"];
    

    growingComment.delegate = self;

//    viewComment.internalTextView.delegate = self;
//    textComment.leftView = paddingView;
//    textComment.leftViewMode = UITextFieldViewModeAlways;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    viewComment.layer.masksToBounds = NO;
    viewComment.layer.shadowColor = [UIColor blackColor].CGColor;
    viewComment.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewComment.layer.shadowOpacity = 0.5f;
    viewComment.layer.shadowRadius = 2.5f;
    viewComment.layer.shadowPath = shadowPath.CGPath;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tableView addSubview:refreshHeaderView];
    
    if (app.currentUser != nil) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, viewComment.frame.size.height, 0.0);
        self.tableView.scrollIndicatorInsets = contentInsets;

        // Edit Swipe
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedHorizontal)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
        [self.tableView addGestureRecognizer:swipe];

    } else {
        viewComment.hidden = true;
    }
    
    
    if (pic) {
        [self setPicture];
    }
    [self reloadView];
}

- (void)swipedHorizontal {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (void)reloadView {
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.currentUser != nil) {
//        textComment.enabled = true;
    }
    
    [indicatorComment startAnimating];
    
    
    NSString *url = [NSString stringWithFormat:@"picture/%d", [pic.pictureId integerValue]];
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                       
                                       comments = [Comment mutableArrayFromDictionary:JSON withKey:@"comments"];
                                       
                                       [self doneLoadingTableViewData];
                                       loaded = TRUE;
                                       
                                       
                                       //Addition data
                                       [buttonUser loadBackground:user.profilePicture placeholderImage:@"user.gif"];
                                       labelAuthor.text = user.name;
                                       
                                       if (pic == nil) {
                                           pic = [Picture instanceFromDictionary:[JSON objectForKey:@"picture"]];
                                           [self setPicture];
                                       } else {
                                           pic = [Picture instanceFromDictionary:[JSON objectForKey:@"picture"]];
                                       }

                                       if (pic.canEdit) {
                                           buttonEdit.hidden = false;
                                       }
                                       
                                       labelAccess.text = [pic.pageviews stringValue];
                                       if (pic.canVote) {
                                           if (!(pic.isVoted && !app.currentUser))
                                               buttonLike.enabled = YES;
                                       }
                                       
                                       buttonLike.selected = pic.isVoted;
                                       
                                       [self.tableView reloadData];
                                       
                                       LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
                                       if (app.currentUser != nil) {
                                           UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, viewComment.frame.size.height, 0.0);
                                           self.tableView.contentInset = contentInsets;
                                       }
                                       [indicatorComment stopAnimating];                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [indicatorComment stopAnimating];
                                       
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                       message:error.localizedDescription
                                                                                      delegate:nil
                                                                             cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                             otherButtonTitles:nil];
                                       [alert show];
                                   }];
}

- (void)setPicture
{
    float newheight = [LXUtils heightFromWidth:308
                                         width:[pic.width floatValue]
                                        height:[pic.height floatValue]];
    imagePic.frame = CGRectMake(imagePic.frame.origin.x, imagePic.frame.origin.y, 308, newheight);
    
    CGRect frameSubPic;
    frameSubPic.origin = CGPointMake(0, 0);
    frameSubPic.size.width = 320;
    frameSubPic.size.height = newheight + 52 + 31;

    CGRect frameDesc;
    if (pic.descriptionText.length > 0) {
        frameDesc.size = [pic.descriptionText sizeWithFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:11]
                                     constrainedToSize:CGSizeMake(308.0f, MAXFLOAT)
                                         lineBreakMode:NSLineBreakByWordWrapping];
        frameDesc.origin = CGPointMake(6.0, newheight + 48);
        frameSubPic.size.height += frameDesc.size.height + 6;
        labelDesc.frame = frameDesc;
        labelDesc.text = pic.descriptionText;
        labelDesc.hidden = false;
    }
    
    
    viewSubPic.frame = frameSubPic;
    
    CGRect frameHeader = self.tableView.tableHeaderView.frame;
    frameHeader.size.height = frameSubPic.size.height + 25 + 14;
    
    if (pic.isOwner && ([pic.voteCount integerValue] > 0)) {
        CGRect frameVote = scrollVotes.frame;
        frameVote.origin.y = frameHeader.size.height;
        scrollVotes.frame = frameVote;
        frameHeader.size.height += 50;
    }
    

    self.tableView.tableHeaderView.frame = frameHeader;
    
    // Hack, to refresh header height
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    
    [self.tableView setNeedsLayout];

    [viewSubPic setNeedsDisplay];
    
    // ------------------------------ SET DATA
    
    // Do any additional setup after loading the view from its nib.
    
    labelDate.text = [LXUtils timeDeltaFromNow:pic.createdAt];
    [buttonLike setTitle:[pic.voteCount stringValue] forState:UIControlStateNormal];
    
    if ((pic.latitude != nil) && (pic.longitude != nil)) {
        buttonMap.enabled = YES;
    }
    
    //self.view.frame = CGRectMake(0, 0, 320, imagePic.frame.size.height + 100);
    buttonUser.tag = [pic.userId integerValue];
    
    // Style
    buttonUser.clipsToBounds = YES;
    buttonUser.layer.cornerRadius = 3;
    
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:imagePic.bounds];
    imagePic.layer.masksToBounds = NO;
    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imagePic.layer.shadowOpacity = 1.0f;
    imagePic.layer.shadowRadius = 2.0f;
    imagePic.layer.shadowPath = shadowPathPic.CGPath;
    

    [imagePic loadProgess:pic.urlMedium];
    
    if (pic.isOwner && ([pic.voteCount integerValue] > 0)) {
        scrollVotes.hidden = NO;
        NSString *url = [NSString stringWithFormat:@"picture/%d/votes", [pic.pictureId integerValue]];
        LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [[LatteAPIClient sharedClient] getPath:url
                                    parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           NSMutableArray *votes = [User mutableArrayFromDictionary:JSON withKey:@"votes"];
                                           for (UIView *subview in scrollVotes.subviews) {
                                               [subview removeFromSuperview];
                                           }
                                           
                                           NSInteger guestVoteCount = [pic.voteCount integerValue] - votes.count;
                                           NSInteger userVoteCount = 0;
                                           voters = [[NSMutableArray alloc] init];
                                           for (User *voteUser in votes) {
                                               if ([voteUser.userId integerValue] != 0) {
                                                   UIButton *buttonVotedUser = [[UIButton alloc] initWithFrame:CGRectMake(5+45*userVoteCount, 0, 40, 40)];
                                                   [buttonVotedUser addTarget:self action:@selector(showVoter:) forControlEvents:UIControlEventTouchUpInside];
                                                   buttonVotedUser.layer.cornerRadius = 5;
                                                   buttonVotedUser.clipsToBounds = YES;
                                                   buttonVotedUser.tag = userVoteCount;
                                                   [buttonVotedUser loadBackground:voteUser.profilePicture placeholderImage:@"user.gif"];
                                                   [scrollVotes addSubview:buttonVotedUser];
                                                   [voters addObject:voteUser];
                                                   userVoteCount++;
                                               } else
                                                   guestVoteCount++;
                                           }
                                           
                                           
                                           if (guestVoteCount > 0) {
                                               UILabel *labelGuestVote = [[UILabel alloc] initWithFrame:CGRectMake(userVoteCount*45+5, 0, 40, 40)];
                                               labelGuestVote.backgroundColor = [UIColor clearColor];
                                               labelGuestVote.textColor = [UIColor colorWithRed:187.0/255.0 green:184.0/255.0 blue:169.0/255.0 alpha:1];
                                               labelGuestVote.textAlignment = NSTextAlignmentCenter;
                                               labelGuestVote.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:20];
                                               labelGuestVote.text = [NSString stringWithFormat:@"+%d", guestVoteCount];
                                               [scrollVotes addSubview:labelGuestVote];
                                               scrollVotes.contentSize = CGSizeMake(45*userVoteCount + 50, 50);
                                           } else {
                                               scrollVotes.contentSize = CGSizeMake(45*userVoteCount + 5, 50);
                                           }
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           TFLog(@"Something went wrong (Get vote)");
                                           
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                           message:error.localizedDescription
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                 otherButtonTitles:nil];
                                           [alert show];
                                       }];
    } else
        scrollVotes.hidden = true;

}

- (void)viewDidUnload
{
    [self setGestureTap:nil];

    [self setViewSubPic:nil];
    [self setIndicatorComment:nil];
    [self setScrollVotes:nil];
    [self setLabelDesc:nil];
    [self setTableView:nil];
    [self setViewComment:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = [comments objectAtIndex:indexPath.row];
    NSString *strComment = comment.descriptionText;
    CGSize labelSize = [strComment sizeWithFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:11]
                              constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(labelSize.height + 25, 42);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return comments.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LXCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
    
    if (nil == cellComment) {
        cellComment = (LXCellComment*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                          reuseIdentifier:@"Comment"];
    }
    
    Comment *comment = [comments objectAtIndex:indexPath.row];
    [cellComment setComment:comment];
    
    if (!comment.user.isUnregister) {
        cellComment.buttonUser.tag = indexPath.row;
        cellComment.buttonLike.tag = indexPath.row;
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        [cellComment.buttonLike addTarget:self action:@selector(submitLikeComment:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cellComment;
}

- (void)showUser:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    Comment *comment = comments[sender.tag];
    viewUserPage.user = comment.user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
}

- (void)showVoter:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = voters[sender.tag];
    [self.navigationController pushViewController:viewUserPage animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.tableView addGestureRecognizer:gestureTap];
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect containerFrame = viewComment.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardSize.height + containerFrame.size.height);

    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + viewComment.frame.size.height, 0.0);
    self.tableView.contentInset = scrollInsets;
    self.tableView.scrollIndicatorInsets = scrollInsets;
    
    
    CGPoint scrollPoint = CGPointMake(0.0, self.tableView.contentOffset.y + keyboardSize.height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];

    viewComment.frame = containerFrame;
    [self.tableView setContentOffset:scrollPoint];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.tableView removeGestureRecognizer:gestureTap];
    
    CGRect containerFrame = viewComment.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0.0, 0.0, viewComment.frame.size.height, 0.0);
    self.tableView.contentInset = scrollInsets;
    self.tableView.scrollIndicatorInsets = scrollInsets;

    viewComment.frame = containerFrame;
        
    [UIView commitAnimations];
}

- (void)toggleLikeComment:(UIButton*)sender {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (!app.currentUser) {
        sender.enabled = NO;
    }
    Comment *comment = comments[sender.tag];
    
    comment.isVoted = !comment.isVoted;
    BOOL increase = comment.isVoted;
    sender.selected = comment.isVoted;
    
    comment.voteCount = [NSNumber numberWithInteger:[comment.voteCount integerValue] + (increase?1:-1)];

    NSInteger likeCount = [sender.titleLabel.text integerValue];
    NSNumber *num = [NSNumber numberWithInteger:likeCount + (increase?1:-1)];
    [sender setTitle:[num stringValue] forState:UIControlStateNormal];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"1", @"vote_type",
                                  nil];
    if (app.currentUser != nil) {
        [param setObject:[app getToken] forKey:@"token"];
    }
    
    
    NSString *url = [NSString stringWithFormat:@"picture/%d/vote_post", [comment.commentId integerValue]];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters:param
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        TFLog(@"Submited like");
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                        TFLog(@"Something went wrong (Vote)");
                                    }];
}

- (BOOL)sendComment {
    if (growingComment.text.length < 3000) {
        // Submit comment
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                               [app getToken], @"token",
                               growingComment.text, @"description", nil];
        
        NSString *url = [NSString stringWithFormat:@"picture/%d/comment_post", [pic.pictureId integerValue]];
        
        [[LatteAPIClient sharedClient] postPath:url
                                     parameters:param
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            Comment *comment = [Comment instanceFromDictionary:[JSON objectForKey:@"comment"]];
                                            [comments addObject:comment];
                                            NSIndexPath *path = [NSIndexPath indexPathForRow:comments.count-1 inSection:0];
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

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    buttonSend.enabled = growingTextView.text.length > 0;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = viewComment.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	viewComment.frame = r;
}

- (IBAction)touchBackground:(id)sender {
    [growingComment resignFirstResponder];
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)touchSend:(id)sender {
    [self sendComment];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PicEdit"]) {
        LXPicEditViewController *viewEditPic = segue.destinationViewController;
        viewEditPic.picture = pic;
    } else if ([segue.identifier isEqualToString:@"Map"]) {
        LXPicMapViewController *viewMap = (LXPicMapViewController*)segue.destinationViewController;
        viewMap.picture = pic;
    } else if ([segue.identifier isEqualToString:@"DetailInfo"]) {
        LXPicInfoViewController *viewInfo = (LXPicInfoViewController*)segue.destinationViewController;
        viewInfo.picture = pic;
    }
}

- (IBAction)touchLike:(UIButton *)sender {
    [LXUtils toggleLike:sender ofPicture:pic];
}

- (IBAction)showOwner:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = user;
    [self.navigationController pushViewController:viewUserPage animated:YES];

}


- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    
    [self reloadView];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    Comment *comment = comments[indexPath.row];
    return ([comment.user.userId integerValue] == [app.currentUser.userId integerValue]) || pic.isOwner;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Comment* comment = comments[indexPath.row];
        [comments removeObject:comment];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        
        NSString *url = [NSString stringWithFormat:@"picture/comment/%d/delete", [comment.commentId integerValue]];
        [[LatteAPIClient sharedClient] postPath:url
                                     parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                        success:nil
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            [comments insertObject:comment atIndex:indexPath.row];
                                            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                        }];
    }
}



@end
