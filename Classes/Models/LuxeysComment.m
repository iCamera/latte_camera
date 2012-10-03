#import "LuxeysComment.h"

#import "LuxeysUser.h"

@implementation LuxeysComment

@synthesize luxeysCommentId;
@synthesize createdAt;
@synthesize descriptionText;
@synthesize hidden;
@synthesize user;

+ (LuxeysComment *)instanceFromDictionary:(NSDictionary *)aDictionary {

    LuxeysComment *instance = [[LuxeysComment alloc] init];
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
            self.user = [LuxeysUser instanceFromDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"luxeysCommentId"];
    } else if ([key isEqualToString:@"created_at"]) {
        [self setValue:value forKey:@"createdAt"];
    } else if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}



@end
