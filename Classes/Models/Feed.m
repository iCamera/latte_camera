#import "Feed.h"

#import "Picture.h"
#import "User.h"

@implementation Feed

@synthesize count;
@synthesize feedID;
@synthesize model;
@synthesize targets;
@synthesize user;
@synthesize updatedAt;

+ (Feed *)instanceFromDictionary:(NSDictionary *)aDictionary {

    Feed *instance = [[Feed alloc] init];
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
                Picture *populatedMember = [Picture instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.targets = myMembers;

        }

    } else if ([key isEqualToString:@"user"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.user = [User instanceFromDictionary:value];
        }

    } else if ([key isEqualToString:@"updated_at"]) {
        self.updatedAt = [luxeysUtils dateFromJSON:value];
    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"feedID"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}



@end
