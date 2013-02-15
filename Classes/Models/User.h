#import <Foundation/Foundation.h>
#import "ModelObject.h"

@interface UserMailAccept : ModelObject {
    BOOL comment;
    BOOL vote;
}

@property (nonatomic, assign) BOOL comment;
@property (nonatomic, assign) BOOL vote;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end

@interface UserPushAccept : ModelObject {
    BOOL comment;
    BOOL vote;
}

@property (nonatomic, assign) BOOL comment;
@property (nonatomic, assign) BOOL vote;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end

@interface User : ModelObject {

    NSString *age;
    NSString *birthdate;
    NSNumber *birthdatePublic;
    NSNumber *birthyearPublic;
    NSString *bloodType;
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
    NSNumber *userId;
    NSString *introduction;
    BOOL isUnregister;
    NSString *name;
    NSString *occupation;
    NSNumber *pictureStatus;
    NSString *profilePicture;
    NSNumber *voteCount;
    
    //Classmethod
    BOOL isFollowing;
    BOOL isFriend;
    NSNumber *requestToMe;
    NSNumber *requestToUser;
    
    UserMailAccept *mailAccepts;
    UserPushAccept *notifyAccepts;
}

@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *birthdate;
@property (nonatomic, copy) NSNumber *birthdatePublic;
@property (nonatomic, copy) NSNumber *birthyearPublic;
@property (nonatomic, copy) NSString *bloodType;
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
@property (nonatomic, copy) NSNumber *userId;
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, assign) BOOL isUnregister;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *occupation;
@property (nonatomic, copy) NSNumber *pictureStatus;
@property (nonatomic, copy) NSString *profilePicture;
@property (nonatomic, copy) NSNumber *voteCount;

@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL isFriend;
@property (nonatomic, copy) NSNumber *requestToMe;
@property (nonatomic, copy) NSNumber *requestToUser;

@property (nonatomic, strong) UserMailAccept *mailAccepts;
@property (nonatomic, strong) UserPushAccept *notifyAccepts;

+ (User *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
+ (NSMutableArray *)mutableArrayFromDictionary:(NSDictionary *)aDictionary withKey:(NSString *)aKey;

@end


