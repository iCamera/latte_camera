//
//  LXTagDiscussionViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/10/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXTagDiscussionViewController.h"
#import "LXTagViewController.h"
#import "JSQMessages.h"
#import "LatteAPIv2Client.h"
#import "UIImageView+AFNetworking.h"
#import "LXUtils.h"
#import "LXAppDelegate.h"
#import "SocketIOPacket.h"
#import <CommonCrypto/CommonDigest.h>

@interface LXTagDiscussionViewController ()

@end

@implementation LXTagDiscussionViewController {
    NSMutableArray *messages;
    SocketIO *socketIO;
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
    self.navigationItem.title = _tag;
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    self.sender = app.currentUser.name;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    [self loadMore:YES];
    
     socketIO = [[SocketIO alloc] initWithDelegate:self];
    [socketIO connectToHost:kLatteSocketURLString onPort:80];
}

- (void)loadMore:(BOOL)reset {
    LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"hash": _conversationHash}];
    if (!reset && messages.count > 0) {
        params[@"last_id"] = messages[0][@"id"];
    }
    
    [api2 GET:@"message" parameters:params success:^(AFHTTPRequestOperation *operation, NSMutableArray *JSON) {
        if (reset) {
            messages = [[NSMutableArray alloc] init];
        }

        for (NSDictionary *message in JSON) {
            [messages insertObject:message atIndex:0];
        }
        [self.collectionView reloadData];
        if (JSON.count > 0) {
            self.showLoadEarlierMessagesHeader = YES;
        } else {
            self.showLoadEarlierMessagesHeader = NO;
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
    NSDictionary *params = @{@"tag": _tag,
                             @"body": text};
    [api2 POST:@"message" parameters:params success:nil failure:nil];
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
    NSDictionary *message = messages[indexPath.row];
    return [[JSQMessage alloc] initWithText:message[@"body"] sender:message[@"user"][@"name"] date:[LXUtils dateFromString:message[@"created_at"]]];
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
    
    NSDictionary *message = messages[indexPath.item];
    
    if ([message[@"user"][@"name"] isEqualToString:self.sender]) {
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
    NSDictionary *message = messages[indexPath.item];
    
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
        NSDictionary *message = messages[indexPath.item];
        NSDate *date = [LXUtils dateFromString:message[@"created_at"]];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = [messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message[@"user"][@"name"] isEqualToString:self.sender]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        NSDictionary *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([previousMessage[@"user"][@"name"] isEqualToString:message[@"user"][@"name"]]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message[@"user"][@"name"]];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
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
    
    NSDictionary *msg = messages[indexPath.item];
    
    if ([msg[@"user"][@"name"] isEqualToString:self.sender]) {
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
    NSDictionary *currentMessage = messages[indexPath.item];
    if ([currentMessage[@"user"][@"name"] isEqualToString:self.sender]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        NSDictionary *previousMessage = messages[indexPath.item - 1];
        if ([previousMessage[@"user"][@"name"] isEqualToString:currentMessage[@"user"][@"name"]]) {
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
    if ([segue.identifier isEqualToString:@"Tag"]) {
        LXTagViewController *view = segue.destinationViewController;
        view.keyword = _tag;
    }
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    DLog(@"%@", packet.dataAsJSON);
    for (NSDictionary *object in packet.dataAsJSON[@"args"]) {
        if ([packet.name isEqualToString:@"new_message"]) {
            if ([object[@"hash"] isEqualToString:_conversationHash]) {
                [messages addObject:object];
                [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                [self finishReceivingMessage];
            }
        }
    }
    
}

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (void)socketIODidConnect:(SocketIO *)socket {
    [socket sendEvent:@"join" withData:_conversationHash];
}

@end
