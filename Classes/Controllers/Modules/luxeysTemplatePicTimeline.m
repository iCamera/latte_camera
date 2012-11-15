//
//  luxeysTemplatePicTimeline.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/24.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysTemplatePicTimeline.h"

@interface luxeysTemplatePicTimeline ()
@end

@implementation luxeysTemplatePicTimeline

@synthesize buttonPic;
@synthesize labelTitle;
@synthesize labelAccess;
@synthesize labelLike;
@synthesize labelAuthor;
@synthesize labelDate;
@synthesize buttonLike;
@synthesize buttonUser;
@synthesize labelComment;
@synthesize viewStats;
@synthesize buttonComment;
@synthesize buttonInfo;
@synthesize buttonMap;
@synthesize buttonShowComment;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (id)initWithPic:(Picture *)aPic user:(User *)aUser section:(NSInteger)aSection sender:(id)aSender {
    self = [super init];
    if (self) {
        pic = aPic;
        user = aUser;
        section = aSection;
        sender = aSender;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    // NSDictionary* user = [pic objectForKey:@"owner"];
    // Increase counter
    NSString *url = [NSString stringWithFormat:@"api/picture/counter/%d/%d",
                     [pic.pictureId integerValue],
                     [user.userId integerValue]];
    
    [[LatteAPIClient sharedClient] getPath:url
                                      parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                         success:nil
                                         failure:nil];
    // Do any additional setup after loading the view from its nib.
    if (pic.title.length > 0)
        labelTitle.text = pic.title;
    
    [buttonUser loadBackground:user.profilePicture];
    labelAuthor.text = user.name;
    
    [buttonPic loadBackground:pic.urlMedium];
    
    float newheight = [luxeysUtils heightFromWidth:308
                                                  width:[pic.width floatValue]
                                                 height:[pic.height floatValue]];
    labelAccess.text = [pic.pageviews stringValue];
    labelLike.text = [pic.voteCount stringValue];
    labelComment.text = [pic.commentCount stringValue];
    labelDate.text = [luxeysUtils timeDeltaFromNow:pic.createdAt];
    buttonPic.frame = CGRectMake(buttonPic.frame.origin.x, buttonPic.frame.origin.y, 308, newheight);
    viewStats.autoresizingMask = UIViewAutoresizingNone;
    viewStats.frame = CGRectMake(0, newheight + 56, viewStats.frame.size.width, viewStats.frame.size.height);
    
    if (pic.canVote)
        if (!pic.isVoted)
            buttonLike.enabled = YES;
    
    if (pic.canComment) {
        buttonComment.enabled = YES;
    }
    
    if ((pic.latitude != nil) && (pic.longitude != nil)) {
        buttonMap.enabled = YES;
    }

    labelAccess.tag = -[pic.pictureId integerValue];
    buttonLike.tag = [pic.pictureId integerValue];
    buttonMap.tag = [pic.pictureId integerValue];
    buttonInfo.tag = [pic.pictureId integerValue];
    buttonPic.tag = [pic.pictureId integerValue];
    buttonComment.tag = [pic.pictureId integerValue];
    buttonUser.tag = [user.userId integerValue];
    buttonShowComment.tag = section;
    
    [buttonUser addTarget:sender action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPic addTarget:sender action:@selector(showPicWithID:) forControlEvents:UIControlEventTouchUpInside];
    [buttonInfo addTarget:sender action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:sender action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    [buttonLike addTarget:sender action:@selector(submitLike:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMap addTarget:sender action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonShowComment addTarget:sender action:@selector(toggleComment:) forControlEvents:UIControlEventTouchUpInside];
    
    // Style
    buttonUser.layer.cornerRadius = 3;
    buttonUser.clipsToBounds = YES;

//    buttonUser.layer.borderWidth = 2;
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:buttonUser.bounds];
//    buttonUser.layer.masksToBounds = NO;
//    buttonUser.layer.shadowColor = [UIColor blackColor].CGColor;
//    buttonUser.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    buttonUser.layer.shadowOpacity = 0.5f;
//    buttonUser.layer.shadowRadius = 1.5f;
//    buttonUser.layer.shadowPath = shadowPath.CGPath;
    
    buttonPic.layer.borderColor = [[UIColor whiteColor] CGColor];
    buttonPic.layer.borderWidth = 3;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonPic.bounds];
    buttonPic.layer.masksToBounds = NO;
    buttonPic.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonPic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    buttonPic.layer.shadowOpacity = 0.5f;
    buttonPic.layer.shadowRadius = 1.5f;
    buttonPic.layer.shadowPath = shadowPathPic.CGPath;
    
    if (section != 0) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.74f green:0.72f blue:0.66f alpha:1];
        [self.view addSubview:lineView];
    }
    
    buttonShowComment.layer.cornerRadius = 5;
    buttonShowComment.layer.masksToBounds = YES;
    
    buttonShowComment.hidden = [pic.commentCount integerValue] <= 3;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
