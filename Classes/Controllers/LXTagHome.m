//
//  LXTagHome.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/30/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXTagHome.h"
#import "LXTagDiscussionViewController.h"
#import "LatteAPIv2Client.h"
#import "AFNetworking.h"
#import "LXAppDelegate.h"
#import "LatteAPIv2Client.h"
#import "LXStreamBrickCell.h"
#import "LXStreamFooter.h"
#import "LXCollectionCellUser.h"
#import "JSQMessagesInputToolbar.h"
#import "JSQMessagesToolbarContentView.h"
#import "JSQMessagesComposerTextView.h"
#import "LXUserPageViewController.h"


typedef enum {
    kGridPic,
    kGridUser,
} TagGridData;

@interface LXTagHome ()

@end

@implementation LXTagHome {
    BOOL showingKeyboard;
    NSMutableArray *pictures;
    NSMutableArray *users;
    NSInteger page;
    NSInteger limit;
    BOOL loadEnded;
    AFHTTPRequestOperation *currentRequest;
    UIActivityIndicatorView *indicatorLoading;
    TagGridData gridView;
    LXTagDiscussionViewController *tagChat;
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
    _buttonSp.layer.cornerRadius = 13;
    
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
    
    LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
    
    if (app.currentUser) {
        [api2 GET:@"tag/follow" parameters:@{@"tag": _tag} success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            _buttonFollow.enabled = YES;
            _buttonFollow.selected = [JSON[@"is_following"] boolValue];
        } failure:nil];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [api2 GET:@"tag/followers" parameters:@{@"tag": _tag} success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        [_buttonGridFollower setTitle:[JSON[@"total"] stringValue] forState:UIControlStateNormal];
    } failure:nil];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXCellBrick" bundle:nil] forCellWithReuseIdentifier:@"Brick"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LXStreamFooter" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
    
    self.navigationItem.title = _tag;
    
    [self loadMorePublicTagPhoto:YES];
}

- (void)loadMorePublicTagPhoto:(BOOL)reset {
    [indicatorLoading startAnimating];
    if (reset) {
        if (currentRequest.isExecuting) [currentRequest cancel];
        loadEnded = false;
        page = 1;
        limit = 30;
    } else {
        if (currentRequest.isExecuting) return;
    }
    currentRequest = [[LatteAPIClient sharedClient] GET:@"picture/tag"
                                             parameters:@{@"tag": _tag,
                                                          @"limit": [NSNumber numberWithInteger:limit],
                                                          @"page": [NSNumber numberWithInteger:page]}
                                                success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                    
                                                    NSMutableArray *data = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                                    [_buttonGridPhoto setTitle:[JSON[@"total"] stringValue] forState:UIControlStateNormal];
                                                    [_buttonGridPhoto setTitle:[JSON[@"total"] stringValue] forState:UIControlStateSelected];
                                                    
                                                    if (reset) {
                                                        pictures = data;
                                                        gridView = kGridPic;
                                                    } else {
                                                        [pictures addObjectsFromArray:data];
                                                    }
                                                    
                                                    page += 1;
                                                    loadEnded = data.count == 0;
                                                    //[self.refreshControl endRefreshing];
                                                    [self.collectionView reloadData];
                                                    [indicatorLoading stopAnimating];
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    [indicatorLoading stopAnimating];
                                                    //[self.refreshControl endRefreshing];
                                                }];
}

- (void)loadMoreFollower:(BOOL)reset {
    [indicatorLoading startAnimating];
    if (reset) {
        if (currentRequest.isExecuting) [currentRequest cancel];
        loadEnded = false;
        page = 1;
        limit = 30;
    } else {
        if (currentRequest.isExecuting) return;
    }
    currentRequest = [[LatteAPIv2Client sharedClient] GET:@"tag/followers"
                                             parameters:@{@"tag": _tag,
                                                          @"limit": [NSNumber numberWithInteger:limit],
                                                          @"page": [NSNumber numberWithInteger:page]}
                                                success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                    
                                                    if (reset) {
                                                        users = JSON[@"profiles"];
                                                        gridView = kGridUser;
                                                    } else {
                                                        [users addObjectsFromArray:JSON[@"profiles"]];
                                                    }
                                                    
                                                    page += 1;
                                                    loadEnded = users.count >= [JSON[@"total"] integerValue];
                                                    [self.collectionView reloadData];
                                                    [indicatorLoading stopAnimating];
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    [indicatorLoading stopAnimating];
                                                    //[self.refreshControl endRefreshing];
                                                }];
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
        tagChat = segue.destinationViewController;
        tagChat.tag = _tag;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)panView:(UIPanGestureRecognizer *)sender {
    [self.view bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    CGFloat newHeight = _constraintHeight.constant + translatedPoint.y;
    if (newHeight < 0) {
        newHeight = 0;
    }
    
    if (newHeight > 320) {
        newHeight = 320;
    }
    
    if (newHeight > 100) {
        [tagChat.inputToolbar.contentView.textView resignFirstResponder];
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

- (IBAction)touchGridPic:(id)sender {
    [self loadMorePublicTagPhoto:YES];
}

- (IBAction)touchGridFollower:(id)sender {
    [self loadMoreFollower:YES];
}
    
- (IBAction)touchTab:(UIButton *)sender {
    _buttonGridFollower.selected = NO;
    _buttonGridPhoto.selected = NO;
    sender.selected = YES;
    
    [tagChat.inputToolbar.contentView.textView resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        _constraintHeight.constant = 260;
        [self.view layoutIfNeeded];
    }];
    showingKeyboard = false;

    
    if (sender.tag == 0) {
        [self loadMorePublicTagPhoto:YES];
    } else if (sender.tag == 1) {
        [self loadMoreFollower:YES];
    }
}

- (IBAction)touchTagInfo:(id)sender {
    NSString *strUrl = [NSString stringWithFormat:@"http://latte.la/photo/tag/%@", [_tag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
}

- (IBAction)toggleHeight:(id)sender {
    if (_constraintHeight.constant <= 130) {
        _constraintHeight.constant = 260;
        [tagChat.inputToolbar.contentView.textView resignFirstResponder];
    } else {
        _constraintHeight.constant = 0;
    }

    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];

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

- (NSDictionary *)pictureAfterPicture:(Picture *)picture {
    NSUInteger current = [pictures indexOfObject:picture];
    if (current == pictures.count-1) {
        return nil;
    }
    Picture *picNext = pictures[current+1];
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         picNext, @"picture",
                         nil];
    
    if (current > pictures.count - 6) {
        [self loadMorePublicTagPhoto:NO];
    }
    
    return ret;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {
    NSUInteger current = [pictures indexOfObject:picture];
    if (current == 0) {
        return nil;
    }
    Picture *picPrev = pictures[current-1];
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         picPrev, @"picture",
                         nil];
    return ret;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        LXStreamFooter *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:@"Footer"
                                                                               forIndexPath:indexPath];
        indicatorLoading = footerView.indicatorLoading;
        
        if ([currentRequest isExecuting]) {
            [indicatorLoading startAnimating];
        }
        
        if (loadEnded) {
            footerView.imageEmpty.hidden = pictures.count > 0;
        } else {
            footerView.imageEmpty.hidden = YES;
        }

        return footerView;
    }
    
    return nil;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (gridView == kGridPic) {
        LXStreamBrickCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Brick" forIndexPath:indexPath];
        Picture *picture = pictures[indexPath.item];
        cell.picture = picture;
        //cell.user = picture.user;
        
        // Hide
        cell.buttonUser.hidden = YES;
        cell.viewBg.hidden = YES;
        cell.labelUsername.hidden = YES;
        
        cell.delegate = self;
        return cell;
    }
    
    if (gridView == kGridUser) {
        LXCollectionCellUser *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"User" forIndexPath:indexPath];
        cell.user = [User instanceFromDictionary:users[indexPath.item]];
        return cell;
    }

    
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (gridView == kGridPic) {
        return pictures.count;
    }
    
    if (gridView == kGridUser) {
        return users.count;
    }
    
    return 0;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (loadEnded) {
        if (gridView == kGridPic && pictures.count == 0) {
            return CGSizeMake(320, 320);
        }
        if (gridView == kGridUser && pictures.count == 0) {
            return CGSizeMake(320, 320);
        }
    } else {
        return CGSizeMake(320, 50);
    }
    
    return CGSizeZero;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (gridView == kGridPic) {
        return CGSizeMake(100, 100);
    } else {
        return CGSizeMake(50, 50);
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (gridView == kGridUser) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        LXUserPageViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
        viewUser.user = [User instanceFromDictionary:users[indexPath.item]];
        [self.navigationController pushViewController:viewUser animated:YES];

    }
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if (loadEnded)
        return;
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -100;
    if(y > h + reload_distance) {
        if (gridView == kGridPic) {
            [self loadMorePublicTagPhoto:NO];
        }
        if (gridView == kGridUser) {
            [self loadMoreFollower:NO];
        }
        
    }
}


@end
