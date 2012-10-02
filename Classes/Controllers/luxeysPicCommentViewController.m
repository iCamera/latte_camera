//
//  luxeysPicCommentViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/26.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysPicCommentViewController.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "luxeysCellComment.h"

@interface luxeysPicCommentViewController () {
    NSDictionary *pic;
    NSArray *comments;
}

@end

@implementation luxeysPicCommentViewController

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
    gradient.frame = CGRectMake(0, 40, 320, 10);
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
    
    [viewImage setImageWithURL:[NSURL URLWithString:[pic objectForKey:@"url_square"]]];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    NSString *url = [NSString stringWithFormat:@"api/picture/%d", [[pic objectForKey:@"id"] integerValue]];
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             pic = [JSON objectForKey:@"picture"];
                                             NSDictionary *user = [JSON objectForKey:@"user"];
                                             labelAuthor.text = [user objectForKey:@"name"];
                                             labelTitle.text = [pic objectForKey:@"name"];
                                             comments = [JSON objectForKey:@"comments"];
                                             [tableComment reloadData];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (PicInfo)");
                                         }];

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    textComment.leftView = paddingView;
    textComment.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setPic:(NSDictionary *)aPic {
    pic = aPic;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)sendComment {
    if (textComment.text.length < 3000) {
        // Submit comment
        luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                               [app getToken], @"token",
                               textComment.text, @"description", nil];
        
        NSString *url = [NSString stringWithFormat:@"api/picture/%d/comment_post", [[pic objectForKey:@"id"] integerValue]];
        
        [[luxeysLatteAPIClient sharedClient] postPath:url
                                           parameters:param
                                              success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                  NSDictionary *comment = [JSON objectForKey:@"comment"];
                                                  [self dismissViewControllerAnimated:YES completion:^{
                                                      [self.parentViewController performSelector:@selector(submitComment:) withObject:pic withObject:comment];
                                                  }];
                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Something went wrong (Comment)");
                                              }];
        
        return TRUE;
    } else {
        return FALSE;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return comments.count;
}

- (IBAction)touchClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    tableComment.contentInset = contentInsets;
    tableComment.scrollIndicatorInsets = contentInsets;
    
    
    
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
    tableComment.contentInset = contentInsets;
    tableComment.scrollIndicatorInsets = contentInsets;
    
    viewComment.frame = CGRectMake(0,
                                   self.view.frame.size.height-viewComment.frame.size.height,
                                   viewComment.frame.size.width,
                                   viewComment.frame.size.height);
    
       // CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
       // CGPoint scrollPoint = CGPointMake(0.0, tableComment.contentOffset.y - keyboardSize.height);
       // [tableComment setContentOffset:scrollPoint];
    
    [UIView commitAnimations];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    luxeysTableViewCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
    
    if (nil == cellComment) {
        cellComment = (luxeysTableViewCellComment*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                          reuseIdentifier:@"Comment"];
    }
    
    [cellComment setComment:[comments objectAtIndex:indexPath.row]];
    cellComment.buttonUser.tag = indexPath.row;
    [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    
    return cellComment;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return viewHeader.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *comment = [comments objectAtIndex:indexPath.row];
    NSString *strComment = [comment objectForKey:@"description"];
    CGSize labelSize = [strComment sizeWithFont:[UIFont systemFontOfSize:11]
                              constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(labelSize.height + 33, 50);
}

@end
