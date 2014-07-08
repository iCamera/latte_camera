//
//  LXSocketIO.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/8/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXSocketIO.h"
#import "SocketIOPacket.h"
#import "LXAppDelegate.h"

@implementation LXSocketIO

+ (instancetype)sharedClient {
    static LXSocketIO *_socketIO = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Websocket
        _socketIO = [[LXSocketIO alloc] init];
        _socketIO.delegate = _socketIO;
        [_socketIO connectToHost:kLatteSocketURLString onPort:80];
    });
    
    return _socketIO;
}

- (void) socketIODidConnect:(SocketIO *)socket {
    DLog(@"Opened");
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
    DLog(@"Disconnected");
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
    DLog(@"Got message");
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
    DLog(@"Got JSON");
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    NSNotificationCenter *notifier = [NSNotificationCenter defaultCenter];
    DLog(@"%@", packet.dataAsJSON);
    for (id object in packet.dataAsJSON[@"args"]) {
        [notifier postNotificationName:packet.name object:object];
    }
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet {
    DLog(@"Sent Event");
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    DLog(@"Error");
}

@end
