#import <Foundation/Foundation.h>

@class LuxeysUser;

@interface LuxeysComment : NSObject {

    NSNumber *luxeysCommentId;
    NSString *createdAt;
    NSString *descriptionText;
    BOOL hidden;
    LuxeysUser *user;

}

@property (nonatomic, copy) NSNumber *luxeysCommentId;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) LuxeysUser *user;

+ (LuxeysComment *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
