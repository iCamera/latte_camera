#import "Picture.h"

#import "Comment.h"

@implementation Picture

@synthesize canComment;
@synthesize canVote;
@synthesize canEdit;
@synthesize commentCount;
@synthesize comments;
@synthesize createdAt;
@synthesize descriptionText;
@synthesize height;
@synthesize isVoted;
@synthesize latitude;
@synthesize longitude;
@synthesize model;
@synthesize pageviews;
@synthesize takenAt;
@synthesize pictureId;
@synthesize title;
@synthesize urlOrg;
@synthesize urlLarge;
@synthesize urlMedium;
@synthesize urlSmall;
@synthesize urlSquare;
@synthesize voteCount;
@synthesize width;
@synthesize exif;
@synthesize userId;
@synthesize tags;
@synthesize status;
@synthesize isOwner;

+ (Picture *)instanceFromDictionary:(NSDictionary *)aDictionary {
    Picture *instance = [[Picture alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key {

    if ([key isEqualToString:@"comments"]) {

        if ([value isKindOfClass:[NSArray class]]) {

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                Comment *populatedMember = [Comment instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.comments = myMembers;

        }
    } else if ([key isEqualToString:@"created_at"]) {
        self.createdAt = [LXUtils dateFromJSON:value];
    } else if ([key isEqualToString:@"taken_at"]) {
        self.takenAt = [LXUtils dateFromJSON:value];
    } else if ([key isEqualToString:@"tags"]) {
        self.tags = [NSArray arrayWithArray:value];
    }
    else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"can_comment"]) {
        [self setValue:value forKey:@"canComment"];
    } else if ([key isEqualToString:@"can_vote"]) {
        [self setValue:value forKey:@"canVote"];
    } else if ([key isEqualToString:@"can_edit"]) {
        [self setValue:value forKey:@"canEdit"];
    } else if ([key isEqualToString:@"comment_count"]) {
        [self setValue:value forKey:@"commentCount"];
    } else if ([key isEqualToString:@"created_at"]) {
        [self setValue:value forKey:@"createdAt"];
    } else if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"is_voted"]) {
        [self setValue:value forKey:@"isVoted"];
    } else if ([key isEqualToString:@"is_owner"]) {
        [self setValue:value forKey:@"isOwner"];
    } else if ([key isEqualToString:@"taken_at"]) {
        [self setValue:value forKey:@"takenAt"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"pictureId"];
    } else if ([key isEqualToString:@"user_id"]) {
        [self setValue:value forKey:@"userId"];
    } else if ([key isEqualToString:@"url_org"]) {
        [self setValue:value forKey:@"urlOrg"];
    } else if ([key isEqualToString:@"url_large"]) {
        [self setValue:value forKey:@"urlLarge"];
    } else if ([key isEqualToString:@"url_medium"]) {
        [self setValue:value forKey:@"urlMedium"];
    } else if ([key isEqualToString:@"url_small"]) {
        [self setValue:value forKey:@"urlSmall"];
    } else if ([key isEqualToString:@"url_square"]) {
        [self setValue:value forKey:@"urlSquare"];
    } else if ([key isEqualToString:@"vote_count"]) {
        [self setValue:value forKey:@"voteCount"];
    } else if ([key isEqualToString:@"exif"]) {
        [self setValue:value forKey:@"exif"];
    } else if ([key isEqualToString:@"status"]) {
        [self setValue:value forKey:@"status"];
    } else if ([key isEqualToString:@"show_gps"]) {
        [self setValue:value forKey:@"_showGPS"];
    } else if ([key isEqualToString:@"show_exif"]) {
        [self setValue:value forKey:@"_showEXIF"];
    } else if ([key isEqualToString:@"url_absolute"]) {
        [self setValue:value forKey:@"_urlWeb"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}



@end
