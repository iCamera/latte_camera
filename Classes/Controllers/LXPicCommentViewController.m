//
//  luxeysPicCommentViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/26.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXPicCommentViewController.h"


@interface LXPicCommentViewController ()

@end

@implementation LXPicCommentViewController

@synthesize labelAuthor;
@synthesize labelTitle;
@synthesize viewImage;
@synthesize tableComment;
@synthesize viewComment;
@synthesize gestureTap;
@synthesize viewHeader;
@synthesize textComment;
@synthesize buttonSubmit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    viewHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 32, 320, 10);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor clearColor] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2f] CGColor],
                       nil];
    [viewHeader.layer insertSublayer:gradient atIndex:0];

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewImage.bounds];
    viewImage.layer.masksToBounds = NO;
    viewImage.layer.shadowColor = [UIColor blackColor].CGColor;
    viewImage.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    viewImage.layer.shadowOpacity = 1.0f;
    viewImage.layer.shadowRadius = 1.0f;
    viewImage.layer.shadowPath = shadowPath.CGPath;
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    if ([pic.commentCount longValue] != pic.comments.count) { //Comments was not loaded
        LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
        NSString *url = [NSString stringWithFormat:@"picture/%d", picID];
        [[LatteAPIClient sharedClient] getPath:url
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 pic.comments = [Comment mutableArrayFromDictionary:JSON withKey:@"comments"];
                                                 
                                                 [tableComment reloadData];
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 TFLog(@"Something went wrong (PicInfo)");
                                             }];
    }
    
    [viewImage setImageWithURL:[NSURL URLWithString:pic.urlSquare]];
    
    labelAuthor.text = user.name;

    if (pic.title.length > 0)
        labelTitle.text = pic.title;
    else
        labelTitle.text = NSLocalizedString(@"no_title", @"タイトルなし");

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    textComment.leftView = paddingView;
    textComment.leftViewMode = UITextFieldViewModeAlways;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, viewComment.frame.size.height, 0.0);
    tableComment.scrollIndicatorInsets = contentInsets;
}

- (void)setPic:(Picture *)aPic withUser:(User *)aUser withParent:(UIViewController *)aParent {
    pic = aPic;
    picID = [pic.pictureId integerValue];
    user = aUser;
    parent = aParent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)sendComment {
    if (textComment.text.length < 3000) {
        // Submit comment
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                               [app getToken], @"token",
                               textComment.text, @"description", nil];
        
        NSString *url = [NSString stringWithFormat:@"picture/%d/comment_post", picID];
        
        [[LatteAPIClient sharedClient] postPath:url
                                           parameters:param
                                              success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                  Comment *comment = [Comment instanceFromDictionary:[JSON objectForKey:@"comment"]];
                                                  [pic.comments insertObject:comment atIndex:0];
                                                  pic.commentCount = [NSNumber numberWithInteger:[pic.commentCount integerValue] + 1];
                                                  
                                                  [parent performSelector:@selector(submitComment:) withObject:pic];
                                                  [self.navigationController popViewControllerAnimated:YES];
                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  TFLog(@"Something went wrong (Comment)");
                                              }];
        
        return TRUE;
    } else {
        return FALSE;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pic.comments.count;
}

- (IBAction)touchClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    // [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchSubmit:(id)sender {
    [self sendComment];
}

- (IBAction)tapBackground:(id)sender {
    [textComment resignFirstResponder];
}

- (IBAction)changeText:(id)sender {
    buttonSubmit.enabled = textComment.text.length > 0;
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    
    [tableComment addGestureRecognizer:gestureTap];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + viewComment.frame.size.height, 0.0);
    tableComment.contentInset = contentInsets;
    tableComment.scrollIndicatorInsets = scrollInsets;
    
    
    
    viewComment.frame = CGRectMake(0,
                                   self.view.frame.size.height-keyboardSize.height-viewComment.frame.size.height,
                                   viewComment.frame.size.width,
                                   viewComment.frame.size.height);
    
    
    CGPoint scrollPoint = CGPointMake(0.0, tableComment.contentOffset.y + keyboardSize.height);
    [tableComment setContentOffset:scrollPoint];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [tableComment removeGestureRecognizer:gestureTap];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0.0, 0.0, viewComment.frame.size.height, 0.0);
    tableComment.contentInset = contentInsets;
    tableComment.scrollIndicatorInsets = scrollInsets;
    
    viewComment.frame = CGRectMake(0,
                                   self.view.frame.size.height-viewComment.frame.size.height,
                                   viewComment.frame.size.width,
                                   viewComment.frame.size.height);
    
    [UIView commitAnimations];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LXCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
    
    if (nil == cellComment) {
        cellComment = (LXCellComment*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                          reuseIdentifier:@"Comment"];
    }
    Comment *comment = [[[pic.comments reverseObjectEnumerator] allObjects] objectAtIndex:indexPath.row];
    [cellComment setComment:comment];

    if (!comment.user.isUnregister) {
        cellComment.buttonUser.tag = [comment.user.userId integerValue];
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cellComment;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return viewHeader.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = [[[pic.comments reverseObjectEnumerator] allObjects] objectAtIndex:indexPath.row];
    CGSize labelSize = [comment.descriptionText sizeWithFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:11]
                              constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(labelSize.height + 25, 42);
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TabbarHide"
     object:self];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TabbarShow"
     object:self];
    
    [super viewWillDisappear:animated];
}

- (void)showUser:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    [viewUserPage setUserID:sender.tag];
    [self.navigationController pushViewController:viewUserPage animated:YES];
}

@end
