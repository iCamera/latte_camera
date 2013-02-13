#import <Foundation/Foundation.h>
#import "ModelObject.h"
#import "LXUtils.h"

@class User;

@interface Comment : ModelObject {

    NSNumber *commentId;
    NSDate *createdAt;
    NSString *descriptionText;
    BOOL hidden;
    BOOL canEdit;
    User *user;

}

@property (nonatomic, copy) NSNumber *commentId;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, strong) User *user;

+ (Comment *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
