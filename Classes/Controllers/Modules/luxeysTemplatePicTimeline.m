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

@synthesize labelTitle;
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
@synthesize buttonShowComment;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (id)initWithPic:(LuxeysPicture *)aPic user:(LuxeysUser *)aUser section:(NSInteger)aSection sender:(id)aSender {
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
    
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                         success:nil
                                         failure:nil];
    // Do any additional setup after loading the view from its nib.
    labelTitle.text = pic.title;
    
    [buttonUser loadBackground:user.profilePicture];
    labelAuthor.text = user.name;
    
    [imagePic setImageWithURL:[NSURL URLWithString:pic.urlMedium]];
    
    float newheight = [luxeysImageUtils heightFromWidth:300
                                                  width:[pic.width floatValue]
                                                 height:[pic.height floatValue]];
    labelAccess.text = [pic.pageviews stringValue];
    labelLike.text = [pic.voteCount stringValue];
    labelComment.text = [pic.commentCount stringValue];
    imagePic.frame = CGRectMake(imagePic.frame.origin.x, imagePic.frame.origin.y, 300, newheight);
    viewStats.autoresizingMask = UIViewAutoresizingNone;
    viewStats.frame = CGRectMake(0, newheight + 60, viewStats.frame.size.width, viewStats.frame.size.height);
    
    if (pic.canVote)
        if (!pic.isVoted)
            buttonLike.enabled = YES;
    
    if (pic.canComment) {
        buttonComment.enabled = YES;
    }
    
    buttonInfo.tag = [pic.pictureId integerValue];
    buttonComment.tag = [pic.pictureId integerValue];
    buttonUser.tag = [pic.pictureId integerValue];
    buttonShowComment.tag = section;
    
    [buttonUser addTarget:sender action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    [buttonInfo addTarget:sender action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:sender action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    [buttonLike addTarget:sender action:@selector(submitLike:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMap addTarget:sender action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonShowComment addTarget:sender action:@selector(toggleComment:) forControlEvents:UIControlEventTouchUpInside];
    
    // Style
    buttonUser.layer.borderColor = [[UIColor whiteColor] CGColor];
    buttonUser.layer.borderWidth = 2;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:buttonUser.bounds];
    buttonUser.layer.masksToBounds = NO;
    buttonUser.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonUser.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    buttonUser.layer.shadowOpacity = 0.5f;
    buttonUser.layer.shadowRadius = 1.5f;
    buttonUser.layer.shadowPath = shadowPath.CGPath;
    
    imagePic.layer.borderColor = [[UIColor whiteColor] CGColor];
    imagePic.layer.borderWidth = 5;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:imagePic.bounds];
    imagePic.layer.masksToBounds = NO;
    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    imagePic.layer.shadowOpacity = 0.5f;
    imagePic.layer.shadowRadius = 1.5f;
    imagePic.layer.shadowPath = shadowPathPic.CGPath;
    
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
