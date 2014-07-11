//
//  LXTagHome.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/30/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXTagHome.h"
#import "LXTagDiscussionViewController.h"
#import "LXTagViewController.h"
#import "LXAppDelegate.h"
#import "LatteAPIv2Client.h"

@interface LXTagHome ()

@end

@implementation LXTagHome {
    BOOL showingKeyboard;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _labelSp.layer.cornerRadius = 8;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    showingKeyboard = false;
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    if (app.currentUser) {
        LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
        [api2 GET:@"tag/follow" parameters:@{@"tag": _tag} success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            _buttonFollow.enabled = YES;
            _buttonFollow.selected = [JSON[@"is_following"] boolValue];
        } failure:nil];
    }
    
    self.navigationItem.title = _tag;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TagChat"]) {
        LXTagDiscussionViewController *tagChat = segue.destinationViewController;
        tagChat.tag = _tag;
    } else if ([segue.identifier isEqualToString:@"TagPhoto"]) {
        LXTagViewController *tagPhoto = segue.destinationViewController;
        tagPhoto.keyword = _tag;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



- (IBAction)panView:(UIPanGestureRecognizer *)sender {
    if (showingKeyboard) {
        return;
    }
    [self.view bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    CGFloat newHeight = _constraintHeight.constant + translatedPoint.y;
    if (newHeight < 0) {
        newHeight = 0;
    }
    
    if (newHeight > 320) {
        newHeight = 320;
    }
    
    _constraintHeight.constant = newHeight;

    [sender setTranslation:CGPointZero inView:self.view];
}

- (IBAction)tapView:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        _constraintHeight.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)toggleFollow:(id)sender {
    LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
    _buttonFollow.selected = !_buttonFollow.selected;
    
    if (_buttonFollow.selected) {
        [api2 POST:@"tag/follow" parameters:@{@"tag": _tag} success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            _buttonFollow.enabled = YES;
            _buttonFollow.selected = [JSON[@"is_following"] boolValue];
        } failure:nil];
    }

    if (!_buttonFollow.selected) {
        [api2 POST:@"tag/unfollow" parameters:@{@"tag": _tag} success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            _buttonFollow.enabled = YES;
            _buttonFollow.selected = [JSON[@"is_following"] boolValue];
        } failure:nil];
    }
}

- (void)keyboardWillShow:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        _constraintHeight.constant = 0;
        [self.view layoutIfNeeded];
    }];
    showingKeyboard = true;
}

- (void)keyboardWillHide:(id)sender {
    showingKeyboard = false;
}

@end
