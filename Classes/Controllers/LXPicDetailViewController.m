//
//  LXPicDetailViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXPicDetailViewController.h"

@interface LXPicDetailViewController ()
@end

@implementation LXPicDetailViewController

@synthesize picID;
@synthesize gestureTap;
@synthesize viewTextbox;
@synthesize textComment;
@synthesize buttonSend;
@synthesize buttonEdit;
@synthesize tablePic;
@synthesize pic;
//@synthesize user;

@synthesize labelTitle;
@synthesize labelDate;
@synthesize imagePic;
@synthesize labelAccess;
@synthesize labelLike;
@synthesize labelAuthor;
@synthesize buttonLike;
@synthesize buttonUser;
@synthesize labelComment;
@synthesize viewStats;
@synthesize buttonComment;
@synthesize buttonInfo;
@synthesize buttonMap;
@synthesize viewSubBg;
@synthesize viewSubPic;
@synthesize indicatorComment;
@synthesize scrollVotes;

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
    
    // Style
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewTextbox.bounds];
    viewTextbox.layer.masksToBounds = NO;
    viewTextbox.layer.shadowColor = [UIColor blackColor].CGColor;
    viewTextbox.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewTextbox.layer.shadowOpacity = 0.5f;
    viewTextbox.layer.shadowRadius = 2.5f;
    viewTextbox.layer.shadowPath = shadowPath.CGPath;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    textComment.leftView = paddingView;
    textComment.leftViewMode = UITextFieldViewModeAlways;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tablePic.bounds.size.height, self.view.frame.size.width, self.tablePic.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tablePic addSubview:refreshHeaderView];
    
    if (app.currentUser != nil) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, viewTextbox.frame.size.height, 0.0);
        tablePic.scrollIndicatorInsets = contentInsets;

        // Edit Swipe
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedHorizontal)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
        [tablePic addGestureRecognizer:swipe];

    } else {
        viewTextbox.hidden = true;
    }
    
    
    [self setPicture];
    [self reloadView];
}

- (void)swipedHorizontal {
    [tablePic setEditing:!tablePic.editing animated:YES];
}

- (void)reloadView {
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.currentUser != nil) {
        textComment.enabled = true;
    }
    
    [indicatorComment startAnimating];
    
    
    NSString *url = [NSString stringWithFormat:@"picture/%d", pic!=nil?[pic.pictureId integerValue]:picID];
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       User *user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                       
                                       
                                       comments = [Comment mutableArrayFromDictionary:JSON withKey:@"comments"];
                                       
                                       [self doneLoadingTableViewData];
                                       loaded = TRUE;
                                       
                                       
                                       //Addition data
                                       buttonUser.tag = [user.userId integerValue];
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
                                       if (pic.canVote)
                                           if (!pic.isVoted)
                                               buttonLike.enabled = YES;
                                       
                                       if (pic.canComment) {
                                           buttonComment.enabled = YES;
                                       }
                                       
                                       [tablePic reloadData];
                                       
                                       LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
                                       if (app.currentUser != nil) {
                                           UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, viewTextbox.frame.size.height, 0.0);
                                           tablePic.contentInset = contentInsets;
                                       }
                                       [indicatorComment stopAnimating];
                                       
                                       // Increase counter
                                       NSString *url = [NSString stringWithFormat:@"picture/counter/%d/%d",
                                                        [pic.pictureId integerValue],
                                                        [user.userId integerValue]];
                                       
                                       [[LatteAPIClient sharedClient] getPath:url
                                                                   parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                                                      success:nil
                                                                      failure:nil];
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
    
    CGRect frame = tablePic.tableHeaderView.frame;
    frame.size.height = newheight + 98;
    
    if (pic.isOwner && ([pic.voteCount integerValue] > 0)) {
        frame.size.height += 50;
    }
    
    tablePic.tableHeaderView.frame = frame;
    
    // Hack, to refresh header height
    tablePic.tableHeaderView = tablePic.tableHeaderView;

    [tablePic setNeedsLayout];
    [viewSubBg setNeedsDisplay];
    [viewSubPic setNeedsDisplay];
    frame = viewSubPic.frame;
    frame.size.height = newheight + 52;
    viewSubPic.frame = frame;
    
    frame = viewStats.frame;
    frame.origin.y = newheight + 58;
    viewStats.frame = frame;
    
    // Do any additional setup after loading the view from its nib.
    if (pic.title.length > 0)
        labelTitle.text = pic.title;
        
    labelDate.text = [LXUtils timeDeltaFromNow:pic.createdAt];
    labelLike.text = [pic.voteCount stringValue];
    labelComment.text = [pic.commentCount stringValue];
    imagePic.frame = CGRectMake(imagePic.frame.origin.x, imagePic.frame.origin.y, 308, newheight);
    
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
        NSString *url = [NSString stringWithFormat:@"picture/%d/votes", pic!=nil?[pic.pictureId integerValue]:picID];
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
                                           
                                           for (User *voteUser in votes) {
                                               if ([voteUser.userId integerValue] != 0) {
                                                   UIButton *buttonVotedUser = [[UIButton alloc] initWithFrame:CGRectMake(5+45*userVoteCount, 0, 40, 40)];
                                                   [buttonVotedUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
                                                   buttonVotedUser.layer.cornerRadius = 5;
                                                   buttonVotedUser.clipsToBounds = YES;
                                                   buttonVotedUser.tag = [voteUser.userId integerValue];
                                                   [buttonVotedUser loadBackground:voteUser.profilePicture placeholderImage:@"user.gif"];
                                                   [scrollVotes addSubview:buttonVotedUser];

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
    [self setViewTextbox:nil];
    [self setTextComment:nil];
    [self setButtonSend:nil];
    [self setGestureTap:nil];
    [self setTablePic:nil];
    [self setViewSubBg:nil];
    [self setViewSubPic:nil];
    [self setIndicatorComment:nil];
    [self setScrollVotes:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![self.navigationController.viewControllers[self.navigationController.viewControllers.count-2] isKindOfClass:[LXPicDetailViewController class]]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TabbarHide"
         object:self];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (![self.navigationController.viewControllers[self.navigationController.viewControllers.count-1] isKindOfClass:[LXPicDetailViewController class]]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TabbarShow"
         object:self];
    }
    
    [super viewWillDisappear:animated];
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
        cellComment.buttonUser.tag = [comment.user.userId longValue];
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cellComment;
}

- (IBAction)showUser:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    [viewUserPage setUserID:sender.tag];
    [self.navigationController pushViewController:viewUserPage animated:YES];
}

- (IBAction)showInfo:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXPicInfoViewController *viewPicInfo = [mainStoryboard instantiateViewControllerWithIdentifier:@"PictureInfo"];
    [viewPicInfo setPictureID:[pic.pictureId integerValue]];
    [self.navigationController pushViewController:viewPicInfo animated:YES];
}

- (IBAction)showMap:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXPicMapViewController *viewPicMap = [mainStoryboard instantiateViewControllerWithIdentifier:@"PictureMap"];
    [viewPicMap setPointWithLongitude:[pic.longitude floatValue] andLatitude:[pic.latitude floatValue]];
    
    [self.navigationController pushViewController:viewPicMap animated:YES];
}

- (IBAction)showKeyboard:(id)sender {
    [textComment becomeFirstResponder];
}



- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.tablePic addGestureRecognizer:gestureTap];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + viewTextbox.frame.size.height, 0.0);
    tablePic.contentInset = scrollInsets;
    tablePic.scrollIndicatorInsets = scrollInsets;
    
    
 
    viewTextbox.frame = CGRectMake(0,
                                   self.view.frame.size.height-keyboardSize.height-viewTextbox.frame.size.height,
                                   viewTextbox.frame.size.width,
                                   viewTextbox.frame.size.height);
    
    
    CGPoint scrollPoint = CGPointMake(0.0, tablePic.contentOffset.y + keyboardSize.height);
    [tablePic setContentOffset:scrollPoint];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.tablePic removeGestureRecognizer:gestureTap];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0.0, 0.0, viewTextbox.frame.size.height, 0.0);
    tablePic.contentInset = scrollInsets;
    tablePic.scrollIndicatorInsets = scrollInsets;

    viewTextbox.frame = CGRectMake(0,
                                   self.view.frame.size.height-viewTextbox.frame.size.height,
                                   viewTextbox.frame.size.width,
                                   viewTextbox.frame.size.height);
        
    [UIView commitAnimations];
}

- (BOOL)sendComment {
    if (textComment.text.length < 3000) {
        // Submit comment
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                               [app getToken], @"token",
                               textComment.text, @"description", nil];
        
        NSString *url = [NSString stringWithFormat:@"picture/%d/comment_post", [pic.pictureId integerValue]];
        
        [[LatteAPIClient sharedClient] postPath:url
                                     parameters:param
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            Comment *comment = [Comment instanceFromDictionary:[JSON objectForKey:@"comment"]];
                                            [comments addObject:comment];
                                            NSIndexPath *path = [NSIndexPath indexPathForRow:comments.count-1 inSection:0];
                                            [tablePic insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationRight];
                                            [tablePic scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            TFLog(@"Something went wrong (Comment)");
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                            message:error.localizedDescription
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                        }];
        
        textComment.text = @"";
        buttonSend.enabled = false;
        [self.textComment resignFirstResponder];
        return TRUE;
    } else {
        return FALSE;
    }
}

- (IBAction)touchBackground:(id)sender {
    [self.textComment resignFirstResponder];
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeText:(id)sender {
    buttonSend.enabled = textComment.text.length > 0;
}

- (IBAction)touchSend:(id)sender {
    [self sendComment];
}

- (IBAction)touchEdit:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    
    LXPicEditViewController *viewEditPic = [mainStoryboard instantiateViewControllerWithIdentifier:@"PicEdit"];
    viewEditPic.picture = pic;
    [self.navigationController pushViewController:viewEditPic animated:YES];
}

- (IBAction)touchLike:(id)sender {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           @"1", @"vote_type",
                           nil];
    
    NSString *url = [NSString stringWithFormat:@"picture/%d/vote_post", [pic.pictureId integerValue]];
    buttonLike.enabled = NO;
    [[LatteAPIClient sharedClient] postPath:url
                                       parameters:param
                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                              NSNumber *vote_count = [NSNumber numberWithInt:[labelLike.text integerValue] + 1 ];
                                              labelLike.text = [vote_count stringValue];
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              buttonLike.enabled = YES;
                                              TFLog(@"Something went wrong (Vote)");
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                              message:error.localizedDescription
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                    otherButtonTitles:nil];
                                              [alert show];
                                          }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self sendComment];
}

- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tablePic];
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
    return [comment.user.userId integerValue] == [app.currentUser.userId integerValue];;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Comment* comment = comments[indexPath.row];
        [comments removeObject:comment];
        [tablePic deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        
        NSString *url = [NSString stringWithFormat:@"picture/comment/%d/delete", [comment.commentId integerValue]];
        buttonLike.enabled = NO;
        [[LatteAPIClient sharedClient] postPath:url
                                     parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            NSNumber *vote_count = [NSNumber numberWithInt:[labelLike.text integerValue] + 1 ];
                                            labelLike.text = [vote_count stringValue];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            [comments insertObject:comment atIndex:indexPath.row];
                                            [tablePic insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                        }];
    }
}



@end
