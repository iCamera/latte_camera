#import <Foundation/Foundation.h>

@interface LuxeysPicture : NSObject {

    BOOL canComment;
    BOOL canVote;
    NSNumber *commentCount;
    NSMutableArray *comments;
    NSString *createdAt;
    NSString *descriptionText;
    NSNumber *height;
    BOOL isVoted;
    NSNumber *latitude;
    NSNumber *longitude;
    NSString *model;
    NSNumber *pageviews;
    NSString *takenAt;
    NSNumber *luxeysPictureId;
    NSString *title;
    NSString *urlLarge;
    NSString *urlMedium;
    NSString *urlSmall;
    NSString *urlSquare;
    NSNumber *voteCount;
    NSNumber *width;

}

@property (nonatomic, assign) BOOL canComment;
@property (nonatomic, assign) BOOL canVote;
@property (nonatomic, copy) NSNumber *commentCount;
@property (nonatomic, copy) NSMutableArray *comments;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSNumber *height;
@property (nonatomic, assign) BOOL isVoted;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSNumber *pageviews;
@property (nonatomic, copy) NSString *takenAt;
@property (nonatomic, copy) NSNumber *luxeysPictureId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *urlLarge;
@property (nonatomic, copy) NSString *urlMedium;
@property (nonatomic, copy) NSString *urlSmall;
@property (nonatomic, copy) NSString *urlSquare;
@property (nonatomic, copy) NSNumber *voteCount;
@property (nonatomic, copy) NSNumber *width;

+ (LuxeysPicture *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
