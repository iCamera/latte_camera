#import "LuxeysFeed.h"

#import "LuxeysPicture.h"
#import "LuxeysUser.h"

@implementation LuxeysFeed

@synthesize count;
@synthesize userID;
@synthesize model;
@synthesize targets;
@synthesize user;

+ (LuxeysFeed *)instanceFromDictionary:(NSDictionary *)aDictionary {

    LuxeysFeed *instance = [[LuxeysFeed alloc] init];
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

    if ([key isEqualToString:@"targets"]) {

        if ([value isKindOfClass:[NSArray class]]) {

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:((NSArray*)value).count];
            for (id valueMember in value) {
                LuxeysPicture *populatedMember = [LuxeysPicture instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.targets = myMembers;

        }

    } else if ([key isEqualToString:@"user"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.user = [LuxeysUser instanceFromDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"userID"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}



@end
