#import <Foundation/Foundation.h>
#import "ModelObject.h"
#import "luxeysUtils.h"

@class User;

@interface Comment : ModelObject {

    NSNumber *luxeysCommentId;
    NSDate *createdAt;
    NSString *descriptionText;
    BOOL hidden;
    User *user;

}

@property (nonatomic, copy) NSNumber *luxeysCommentId;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) User *user;

+ (Comment *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
