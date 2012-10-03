#import <Foundation/Foundation.h>
#import "LuxeysObject.h"

@class LuxeysUser;

@interface LuxeysFeed : LuxeysObject {
    NSNumber *feedID;
    NSNumber *count;
    NSNumber *model;
    NSMutableArray *targets;
    LuxeysUser *user;

}

@property (nonatomic, copy) NSNumber *feedID;
@property (nonatomic, copy) NSNumber *count;
@property (nonatomic, copy) NSNumber *model;
@property (nonatomic, retain) NSMutableArray *targets;
@property (nonatomic, strong) LuxeysUser *user;

+ (LuxeysFeed *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
