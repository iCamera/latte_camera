#import "Comment.h"

#import "User.h"

@implementation Comment

@synthesize commentId;
@synthesize createdAt;
@synthesize descriptionText;
@synthesize hidden;
@synthesize canEdit;
@synthesize user;

+ (Comment *)instanceFromDictionary:(NSDictionary *)aDictionary {

    Comment *instance = [[Comment alloc] init];
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
    if ([key isEqualToString:@"user"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.user = [User instanceFromDictionary:value];
        }

    } else if ([key isEqualToString:@"created_at"]) {
        self.createdAt = [LXUtils dateFromJSON:value];
    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"commentId"];
    } else if ([key isEqualToString:@"created_at"]) {
        [self setValue:value forKey:@"createdAt"];
    } else if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"can_edit"]) {
        [self setValue:value forKey:@"canEdit"];
    } else if ([key isEqualToString:@"is_voted"]) {
        [self setValue:value forKey:@"_isVoted"];
    } else if ([key isEqualToString:@"vote_count"]) {
        [self setValue:value forKey:@"_voteCount"];
    } else if ([key isEqualToString:@"can_vote"]) {
        [self setValue:value forKey:@"_canVote"];

    } else {
        [super setValue:value forUndefinedKey:key];
    }

}



@end
