#import <Foundation/Foundation.h>

@interface LuxeysUser : NSObject {

    NSString *age;
    NSString *birthdate;
    NSNumber *birthdatePublic;
    NSNumber *birthyearPublic;
    NSNumber *countFollows;
    NSNumber *countFriends;
    NSNumber *countPictures;
    NSString *currentResidence;
    NSNumber *currentResidencePublic;
    NSNumber *gender;
    NSNumber *genderPublic;
    NSString *hobby;
    NSString *hometown;
    NSNumber *hometownPublic;
    NSNumber *luxeysUserId;
    NSString *introduction;
    BOOL isUnregister;
    NSString *name;
    NSString *occupation;
    NSNumber *pictureStatus;
    NSString *profilePicture;
    NSNumber *voteCount;

}

@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *birthdate;
@property (nonatomic, copy) NSNumber *birthdatePublic;
@property (nonatomic, copy) NSNumber *birthyearPublic;
@property (nonatomic, copy) NSNumber *countFollows;
@property (nonatomic, copy) NSNumber *countFriends;
@property (nonatomic, copy) NSNumber *countPictures;
@property (nonatomic, copy) NSString *currentResidence;
@property (nonatomic, copy) NSNumber *currentResidencePublic;
@property (nonatomic, copy) NSNumber *gender;
@property (nonatomic, copy) NSNumber *genderPublic;
@property (nonatomic, copy) NSString *hobby;
@property (nonatomic, copy) NSString *hometown;
@property (nonatomic, copy) NSNumber *hometownPublic;
@property (nonatomic, copy) NSNumber *luxeysUserId;
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, assign) BOOL isUnregister;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *occupation;
@property (nonatomic, copy) NSNumber *pictureStatus;
@property (nonatomic, copy) NSString *profilePicture;
@property (nonatomic, copy) NSNumber *voteCount;

+ (LuxeysUser *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
