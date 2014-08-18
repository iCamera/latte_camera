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
    
    labelDate.text = [LXUtils timeDeltaFromNow:updatedAt];
    labelNote.text = note;
    labelTitle.text = title;
    // TODOS: Complete Notification number.
    //    NSNumber *read = notify[@"read"];
    //    if (read) {
    //        self.highlighted = ![read boolValue];
    //    }
    
    if ([notify[@"read"] boolValue]) {
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor colorWithRed:222.0/255.0 green:238.0/255.0 blue:236.0/255.0 alpha:1];
    }
}

@end
