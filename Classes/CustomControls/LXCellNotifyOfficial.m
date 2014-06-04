//
//  LXCellNotifyOfficial.m
//  Latte camera
//
//  Created by Serkan Unal on 6/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//
#import "LXCellNotifyOfficial.h"
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@implementation LXCellNotifyOfficial

@synthesize viewImage;
@synthesize labelDate;
@synthesize labelNote;
@synthesize labelTitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
}

- (void)setNotify:(NSDictionary *)notify {
   
    NSDate *updatedAt = nil;
    updatedAt = [LXUtils dateFromJSON:[notify objectForKey:@"updated_at"]];
    NSString *title = [notify objectForKey:@"title"];
    NSString *note = [notify objectForKey:@"note"];
    viewImage.image = [UIImage imageNamed:@"Icon-40@2x.png"]; // logo.png
    viewImage.layer.cornerRadius = 5.0f;
    viewImage.layer.borderWidth = 1;
    viewImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewImage.layer.masksToBounds = YES;
    
    labelDate.text = [LXUtils timeDeltaFromNow:updatedAt];
    labelNote.text = note;
    labelTitle.text = title;
    // TODOS: Complete Notification number.
    //    NSNumber *read = notify[@"read"];
    //    if (read) {
    //        self.highlighted = ![read boolValue];
    //    }
    
}

@end
