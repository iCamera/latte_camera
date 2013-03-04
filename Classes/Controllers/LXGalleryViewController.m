//
//  LXGalleryViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXGalleryViewController.h"
#import "LXZoomPictureViewController.h"

#import "LXPicInfoViewController.h"
#import "LXPicDetailViewController.h"
#import "LXPicMapViewController.h"

@interface LXGalleryViewController ()

@end

@implementation LXGalleryViewController {
    NSMutableArray *images;
    UIPageViewController *pageController;
}

@synthesize buttonComment;
@synthesize buttonLike;
@synthesize buttonMap;

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
    images = [[NSMutableArray alloc] init];
    pageController = [[UIPageViewController alloc] init];

    pageController.dataSource = self;
    pageController.delegate = self;
    CGRect frame = self.view.bounds;
    frame.size.height -= 31;
    pageController.view.frame = frame;
    LXZoomPictureViewController *init = [[LXZoomPictureViewController alloc] init];
    init.picture = _picture;
    init.view.bounds = frame;
    
    [pageController setViewControllers:[NSArray arrayWithObject:init]
                             direction:UIPageViewControllerNavigationDirectionForward
                              animated:YES
                            completion:nil];

    [self addChildViewController:pageController];
    [self.view insertSubview:pageController.view atIndex:0];
    [pageController didMoveToParentViewController:self];
    [self setPicture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(LXZoomPictureViewController *)viewController {
    Picture *nextPic = [_delegate pictureAfterPicture:viewController.picture];
    if (nextPic != nil) {
        LXZoomPictureViewController *view = [[LXZoomPictureViewController alloc] init];
        view.picture = nextPic;
        view.view.frame = pageViewController.view.bounds;
        return view;
    } else
        return nil;

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(LXZoomPictureViewController *)viewController {
    Picture *prevPic = [_delegate pictureBeforePicture:viewController.picture];
    if (prevPic != nil) {
        LXZoomPictureViewController *view = [[LXZoomPictureViewController alloc] init];
        view.picture = prevPic;
        view.view.frame = pageViewController.view.bounds;
        return view;
    } else
        return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        [self setPicture];
    }
}

- (void)setPicture {
    LXZoomPictureViewController *currentInfo = pageController.viewControllers[0];
    Picture *currentPicture = currentInfo.picture;
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];

    buttonLike.enabled = NO;
    if (currentPicture.canVote) {
        if (!(currentPicture.isVoted && !app.currentUser))
            buttonLike.enabled = YES;
    }
    buttonLike.selected = currentPicture.isVoted;
    
    if ((currentPicture.latitude != nil) && (currentPicture.longitude != nil)) {
        buttonMap.enabled = YES;
    } else {
        buttonMap.enabled = NO;
    }
    
    [buttonComment setTitle:[currentPicture.commentCount stringValue] forState:UIControlStateNormal];
    [buttonLike setTitle:[currentPicture.voteCount stringValue] forState:UIControlStateNormal];
    
    // Increase counter
    NSString *url = [NSString stringWithFormat:@"picture/counter/%d/%d",
                     [currentPicture.pictureId integerValue],
                     [currentPicture.userId integerValue]];
    
    [[LatteAPIClient sharedClient] getPath:url
                                parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                   success:nil
                                   failure:nil];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LXZoomPictureViewController *currentInfo = pageController.viewControllers[0];
    Picture *currentPicture = currentInfo.picture;
    
    if ([segue.identifier isEqualToString:@"DetailInfo"]) {
        LXPicInfoViewController *viewInfo = (LXPicInfoViewController*)segue.destinationViewController;
        viewInfo.pictureID = [currentPicture.pictureId integerValue];
    } else if ([segue.identifier isEqualToString:@"Comment"]) {
        LXPicDetailViewController *viewInfo = (LXPicDetailViewController*)segue.destinationViewController;
        viewInfo.pic = currentPicture;
    } else if ([segue.identifier isEqualToString:@"Map"]) {
        LXPicMapViewController *viewMap = (LXPicMapViewController*)segue.destinationViewController;
        [viewMap setPointWithLongitude:[currentPicture.longitude floatValue] andLatitude:[currentPicture.latitude floatValue]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleLike:(UIButton *)sender {
    LXZoomPictureViewController *currentInfo = pageController.viewControllers[0];
    [LXUtils toggleLike:sender ofPicture:currentInfo.picture];
}
- (void)viewDidUnload {
    [self setButtonLike:nil];
    [self setButtonComment:nil];
    [self setButtonMap:nil];
    [super viewDidUnload];
}
@end
