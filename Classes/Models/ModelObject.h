//
//  LuxeysObject.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/02.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PictureStatusPrivate = 0,
    PictureStatusFriendsOnly = 10,
    PictureStatusFriendsOfFriends = 20,
    PictureStatusMember = 30,
    PictureStatusPublic = 40,
} PictureStatus;

@interface ModelObject : NSObject

+ (NSMutableArray *)mutableArrayFromDictionary:(NSDictionary *)aDictionary withKey:(NSString *)aKey;
+ (NSObject *)instanceFromDictionary:(NSDictionary *)aDictionary;

@end
