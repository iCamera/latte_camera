#import <Foundation/Foundation.h>
#import "ModelObject.h"
#import "LXUtils.h"

@class User;

@interface Feed : ModelObject {
    NSNumber *feedID;
    NSNumber *count;
    NSNumber *model;
    NSDate *updatedAt;
    NSMutableArray *targets;
    User *user;

}

@property (nonatomic, copy) NSNumber *feedID;
@property (nonatomic, copy) NSNumber *count;
@property (nonatomic, copy) NSNumber *model;
@property (nonatomic, retain) NSMutableArray *targets;
@property (nonatomic, strong) User *user;
@property (nonatomic, copy) NSDate *updatedAt;

+ (Feed *)instanceFromDictionary:(NSDictionary *)aDictionary;
+ (NSMutableArray *)mutableArrayFromPictures:(NSArray *)pictures;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSArray*)tags;

@end
