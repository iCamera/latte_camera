//
//  LXTagDiscussionViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/10/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXTagDiscussionViewController.h"
#import "JSQMessages.h"
#import "LatteAPIv2Client.h"
#import "UIImageView+AFNetworking.h"
#import "LXUtils.h"
#import "LXAppDelegate.h"
#import "LXUserPageViewController.h"
#import "LXReportAbuseMessageViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "LXSocketIO.h"
#import "User.h"
#import "LXTagHome.h"

@interface LXTagDiscussionViewController ()

@end

@implementation LXTagDiscussionViewController {
    NSMutableArray *rawMessages;
}


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
    if (_tag) {
        self.navigationItem.title = _tag;
    }
    
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:[UIColor colorWithRed:111.0/255.0 green:189.0/255.0 blue:187.0/255.0 alpha:1]];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    self.sender = app.currentUser.name;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.automaticallyScrollsToMostRecentMessage = YES;
//    self.showLoadEarlierMessagesHeader = YES;
    
    [self loadMore:YES];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:@"new_message" object:nil];
    
    LXSocketIO *socket = [LXSocketIO sharedClient];
    [socket sendEvent:@"join" withData:_conversationHash];
}

- (void)loadMore:(BOOL)reset {
    LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"hash": _conversationHash,
                                                                                  @"limit": @"500"}];
    if (!reset && rawMessages.count > 0) {
        params[@"last_id"] = rawMessages[0][@"id"];
    }
    
    [api2 GET:@"message" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        if (reset) {
            rawMessages = [[NSMutableArray alloc] init];
            self.messages = [[NSMutableArray alloc] init];
        }

        for (NSDictionary *rawMessage in JSON[@"messages"]) {
            [rawMessages insertObject:rawMessage atIndex:0];
            
            JSQMessage *message = [[JSQMessage alloc] initWithText:rawMessage[@"body"] sender:rawMessage[@"user"][@"name"] date:[LXUtils dateFromString:rawMessage[@"created_at"]]];
            [self.messages insertObject:message atIndex:0];
        }

        [self.collectionView reloadData];
        
        if (reset) {
            [self scrollToBottomAnimated:YES];
        }
    } failure:nil];
}

- (void)setTag:(NSString *)tag {
    _tag = tag;
    _conversationHash = [self sha1:[_tag lowercaseString]];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                    sender:(NSString *)sender
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessage];
    
    LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
    NSString *url = [NSString stringWithFormat:@"message/%@", _conversationHash];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"body": text}];
    if (_tag) {
        params[@"tag"] = _tag;
    }
    [api2 POST:url parameters:params success:nil failure:nil];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    NSLog(@"Camera pressed!");
    /**
     *  Accessory button has no default functionality, yet.
     */
}



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     */
    
    /**
     *  Reuse created bubble images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and bubbles would disappear from cells
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.sender isEqualToString:self.sender]) {
    
        return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
                                 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
                             highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Reuse created avatar images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and avatars would disappear from cells
     *
     *  Note: these images will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    NSDictionary *message = rawMessages[indexPath.item];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    imageView.image = [UIImage imageNamed:@"user.gif"];
    imageView.layer.cornerRadius = 17;
    imageView.layer.masksToBounds = YES;
    [imageView setImageWithURL:[NSURL URLWithString:message[@"user"][@"profile_picture"]] placeholderImage:[UIImage imageNamed:@"user.gif"]];
    return imageView;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        JSQMessagesTimestampFormatter *formater = [JSQMessagesTimestampFormatter sharedFormatter];

        NSString *relativeDate = [formater relativeDateForDate:message.date];
        return [[NSMutableAttributedString alloc] initWithString:relativeDate
                                               attributes:formater.dateTextAttributes];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.sender isEqualToString:self.sender]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:message.sender]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.sender];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage sender] isEqualToString:self.sender]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:[currentMessage sender]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    [self loadMore:NO];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *destructiveButtonTitle = NSLocalizedString(@"report", @"");
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    if ([message.sender isEqualToString:self.sender]) {
        destructiveButtonTitle = NSLocalizedString(@"Remove This Message", @"");
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"View Profile", @""), destructiveButtonTitle, nil];
    actionSheet.destructiveButtonIndex = 1;
    actionSheet.tag = indexPath.item;
    [actionSheet showInView:self.view];
    

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDictionary *rawMessage = rawMessages[actionSheet.tag];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    if (buttonIndex == 0) {
        LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
        
        User *user = [User instanceFromDictionary:rawMessage[@"user"]];
        viewUserPage.user = user;
        
        [self.navigationController pushViewController:viewUserPage animated:YES];
    } else if(buttonIndex == 1) {
        JSQMessage *message = [self.messages objectAtIndex:actionSheet.tag];
        if ([message.sender isEqualToString:self.sender]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"Are you sure you want to remove this message?", @"")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                                  otherButtonTitles:NSLocalizedString(@"Remove", @""), nil];
            alert.tag = actionSheet.tag;
            [alert show];
        } else {
            LXReportAbuseMessageViewController *viewReport = [mainStoryboard instantiateViewControllerWithIdentifier:@"ReportMessage"];
            
            viewReport.message = rawMessage;
            
            [self.navigationController pushViewController:viewReport animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSDictionary *rawMessage = rawMessages[alertView.tag];
        NSString *url = [NSString stringWithFormat:@"message/%ld", [rawMessage[@"id"] longValue]];
        [[LatteAPIv2Client sharedClient] DELETE:url parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            [self loadMore:YES];
                                        } failure:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.inputToolbar.contentView.textView resignFirstResponder];
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)newMessage:(NSNotification *)notification {
    NSDictionary *rawMessage = notification.object;
    
    if ([rawMessage[@"hash"] isEqualToString:_conversationHash]) {
        JSQMessage *message = [[JSQMessage alloc] initWithText:rawMessage[@"body"] sender:rawMessage[@"user"][@"name"] date:[LXUtils dateFromString:rawMessage[@"created_at"]]];
        [rawMessages addObject:rawMessage];
        [self.messages addObject:message];
        
        if (![message.sender isEqualToString:self.sender]) {
            [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        }
        
        [self finishReceivingMessage];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//    [self loadMore:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == 0) {
//        [self loadMore:NO];
    }
}

-(NSString*) sha1:(NSString*)input
{
    NSData *plainData = [input.lowercaseString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    
    const char *cstr = [base64String cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:base64String.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}


- (IBAction)touchPhoto:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];

    LXTagHome *tagHome = [mainStoryboard instantiateViewControllerWithIdentifier:@"TagHome"];
    tagHome.tag = _tag;
    [self.navigationController pushViewController:tagHome animated:YES];
}
@end
