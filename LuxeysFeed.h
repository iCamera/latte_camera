#import <Foundation/Foundation.h>

@class LuxeysUser;

@interface LuxeysFeed : NSObject {

    NSNumber *count;
    NSNumber *userID;
    NSNumber *model;
    NSMutableArray *targets;
    LuxeysUser *user;

}

@property (nonatomic, copy) NSNumber *count;
@property (nonatomic, copy) NSNumber *userID;
@property (nonatomic, copy) NSNumber *model;
@property (nonatomic, copy) NSMutableArray *targets;
@property (nonatomic, strong) LuxeysUser *user;

+ (LuxeysFeed *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
