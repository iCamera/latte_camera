//
//  luxeysMypageViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXMyPageViewController.h"
#import "LXUserPageViewController.h"

#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "LXCellFriend.h"
#import "LXUtils.h"
#import "LXPicInfoViewController.h"
#import "LXPicMapViewController.h"
#import "Feed.h"
#import "User.h"
#import "Picture.h"
#import "UIActionSheet+ButtonState.h"
#import "LXCellTimelineSingle.h"
#import "LXCellTimelineMulti.h"
#import "LXVoteViewController.h"
#import "MBProgressHUD.h"

#import "LXCellGrid.h"
#import "LXCaptureViewController.h"


typedef enum {
    kTimelineAll = 10,
    kTimelineFriends = 12,
    kTimelineFollowing = 13,
} LatteTimeline;

#define kModelPicture 1

@interface LXMyPageViewController ()

@end

@implementation LXMyPageViewController  {
    BOOL reloading;
    BOOL endedTimeline;
    
    int pagePic;

    NSMutableArray *feeds;
    LatteTimeline timelineKind;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    endedTimeline = false;
    
    timelineKind = kTimelineAll;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    [app.tracker set:kGAIScreenName
               value:@"Home Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTimeline:) name:@"LoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:@"BecomeActive" object:nil];
    
    [self reloadView];
}

- (void)reloadView {
    [self loadMore:YES];
}

- (IBAction)refresh:(id)sender {
    [self loadMore:YES];
}

- (void)loadMore:(BOOL)reset {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"listtype": [NSNumber numberWithInteger:timelineKind]}];
    if (reset) {
        endedTimeline = false;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else {
        Feed *feed = feeds.lastObject;
        if (feed) {
            [params setObject:feed.feedID forKey:@"last_id"];
        }
    }
    
    
    [[LatteAPIClient sharedClient] GET: @"user/me/timeline"
                                parameters: params
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       
                                       NSMutableArray *newFeed = [Feed mutableArrayFromDictionary:JSON
                                                                                          withKey:@"feeds"];
                                       
                                       endedTimeline = newFeed.count == 0;
                                       
                                       if (reset) {
                                           feeds = newFeed;
                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       } else {
                                           [feeds addObjectsFromArray:newFeed];
                                       }
                                       
                                       [self.tableView reloadData];
                                       [self.refreshControl endRefreshing];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Timeline)");
                                       
                                       [self.refreshControl endRefreshing];
                                   }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (feeds.count > 0 && !endedTimeline) {
        return feeds.count + 1;
    } else {
        return feeds.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > feeds.count - 1) {
        return 45;
    }

    Feed *feed = feeds[indexPath.row];
    if (feed.targets.count > 1) {
        return 206;
    } else if (feed.targets.count == 1) {
        Picture *pic = feed.targets[0];
        CGFloat feedHeight = [LXUtils heightFromWidth:320.0 width:[pic.width floatValue] height:[pic.height floatValue]] + 3+6+30+6+6+31+3;
        return feedHeight;
    } else
        return 1;
}

- (BOOL)checkEmpty {
    return feeds.count == 0 && endedTimeline;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self checkEmpty]) {
        UIView *emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
        UIImageView *emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nopict.png"]];
        emptyImage.center = emptyView.center;
        [emptyView addSubview:emptyImage];
        return emptyView;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self checkEmpty])
        return 200;
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == feeds.count) {
        [self loadMore:NO];
        return [tableView dequeueReusableCellWithIdentifier:@"Load" forIndexPath:indexPath];
    } else {
        Feed *feed = [feeds objectAtIndex:indexPath.row];
        if (feed.targets.count == 1) {
            
            LXCellTimelineSingle *cell = [tableView dequeueReusableCellWithIdentifier:@"Single" forIndexPath:indexPath];
            
            cell.viewController = self;
            cell.feed = feed;
            cell.buttonUser.tag = indexPath.row;
            
            return cell;
        } else {
            LXCellTimelineMulti *cell = [tableView dequeueReusableCellWithIdentifier:@"Multi" forIndexPath:indexPath];
            
            cell.viewController = self;
            cell.feed = feed;
            cell.buttonUser.tag = indexPath.row;
            
            return cell;
        }
    }
}


- (void)switchTimeline:(UISegmentedControl*)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            timelineKind = kTimelineAll;
            break;
        case 1:
            timelineKind = kTimelineFollowing;
            break;
        case 2:
            timelineKind = kTimelineFriends;
            break;
        default:
            break;
            
    }
    
    [self loadMore:YES];
    
}

- (void)touchSetProfilePic {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"change_profile_pic", @"プロフィール")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                         destructiveButtonTitle:NSLocalizedString(@"remove_profile_pic", @"削除する")
                                              otherButtonTitles:NSLocalizedString(@"select_profile_pic", @"写真を選択する"), nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self deleteProfilePic];
            break;
        case 1:
            [self pickPhoto];
            break;
        default:
            break;
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.currentUser.profilePicture == nil) {
        [actionSheet setButton:0 toState:false];
    }
}


- (void)deleteProfilePic {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[LatteAPIClient sharedClient] POST:@"user/me/profile_picture_delete"
                                 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [app getToken], @"token", nil]
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {

                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        DLog(@"Something went wrong (Delete profile pic)");
                                    }];

}

- (void)pickPhoto {
    LatteAPIClient *api = [LatteAPIClient sharedClient];
    if (api.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                        message:NSLocalizedString(@"Network connectivity is not available", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"close", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
    UINavigationController *navCamera = [storySetting instantiateInitialViewController];

    LXCaptureViewController *controllerCamera = navCamera.viewControllers[0];
    controllerCamera.delegate = self;
    
    [self presentViewController:navCamera animated:YES completion:nil];
}

- (void)imagePickerController:(LXCanvasViewController *)picker didFinishPickingMediaWithData:(NSDictionary *)info {
    UIViewController *tmp2 = picker.navigationController.presentingViewController;    
    [picker dismissViewControllerAnimated:NO completion:nil];
    [tmp2 dismissViewControllerAnimated:YES completion:nil];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    MBProgressHUD *progessHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progessHUD];
    
    progessHUD.mode = MBProgressHUDModeDeterminate;
    [progessHUD show:YES];
    
    void (^createForm)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:[info objectForKey:@"data"]
                                    name:@"file"
                                fileName:@"latte.jpg"
                                mimeType:@"image/jpeg"];
    };
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token", nil];
    
    LatteAPIClient *api = [LatteAPIClient sharedClient];
    NSMutableURLRequest *request = [api.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                URLString:[[NSURL URLWithString:@"user/me/profile_picture" relativeToURL:api.baseURL] absoluteString]
                                               parameters:params
                                constructingBodyWithBlock:createForm error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successUpload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        progessHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        progessHUD.mode = MBProgressHUDModeCustomView;
        [progessHUD hide:YES afterDelay:1];
    };
    
    void (^failUpload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.response statusCode] != 200){
            DLog(@"Upload Failed");
            return;
        }
        DLog(@"error: %@", [operation error]);
        progessHUD.mode = MBProgressHUDModeText;
        progessHUD.labelText = @"Error";
        progessHUD.margin = 10.f;
        progessHUD.yOffset = 150.f;
        progessHUD.removeFromSuperViewOnHide = YES;
        
        [progessHUD hide:YES afterDelay:2];
    };
    
    [operation setCompletionBlockWithSuccess: successUpload failure: failUpload];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
        progessHUD.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    }];
    
    [operation start];
}

- (void)showTimeline:(NSNotification *) notification {
    [self reloadView];
}

- (void)becomeActive:(NSNotification *) notification {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.currentUser != nil) {
        [self reloadView];
    }
}

- (void)showInfo:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabInfo];
}

- (void)showPic:(UIButton*)sender withTab:(GalleryTab)tab {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    Feed *feed = [LXUtils feedFromPicID:sender.tag of:feeds];
    viewGallery.user = feed.user;
    
    [self presentViewController:navGalerry animated:YES completion:^{
        switch (tab) {
            case kGalleryTabComment:
            case kGalleryTabInfo:
            case kGalleryTabVote:
                viewGallery.currentTab = tab;
                break;
            default:
                break;
        }
    }];
}

- (void)showPic:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabNone];
}


- (NSMutableArray*)flatPictureArray {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (Feed *feed in feeds) {
        for (Picture *picture in feed.targets) {
            [ret addObject:picture];
        }
    }
    return ret;
}

- (NSDictionary *)pictureAfterPicture:(Picture *)picture {
    NSArray *flatPictures = [self flatPictureArray];
    NSUInteger current = [flatPictures indexOfObject:picture];
    
    if (current != NSNotFound && current < flatPictures.count-1) {
        Picture *nextPic = [flatPictures objectAtIndex:current+1];
        Feed* feed = [LXUtils feedFromPicID:[nextPic.pictureId integerValue] of:feeds];
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             nextPic, @"picture",
                             feed.user, @"user",
                             nil];
        // Loadmore
        if (current > flatPictures.count - 6)
            [self loadMore:NO];
        return ret;
    }
    return nil;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {
    NSArray *flatPictures = [self flatPictureArray];
    NSInteger current = [flatPictures indexOfObject:picture];
    if (current != NSNotFound && current > 0) {
        Picture *prevPic = [flatPictures objectAtIndex:current-1];
        Feed* feed = [LXUtils feedFromPicID:[prevPic.pictureId integerValue] of:feeds];
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             prevPic,  @"picture",
                             feed.user, @"user",
                             nil];
        return ret;
    }
    return nil;
}

- (void)showLike:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabVote];
}


- (void)showComment:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabComment];
}

- (void)showUser:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    
    Feed *feed = feeds[sender.tag];
    viewUserPage.user = feed.user;
    [self.navigationController pushViewController:viewUserPage animated:YES];

}

- (void)submitLike:(UIButton*)sender {
    Picture *pic = [LXUtils picFromPicID:sender.tag of:feeds];
    [LXUtils toggleLike:sender ofPicture:pic];
}

- (void)showUser:(User *)user fromGallery:(LXGalleryViewController *)gallery {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TimelineHideDesc"
         object:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TimelineShowDesc"
     object:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TimelineHideDesc"
     object:self];
}

@end
