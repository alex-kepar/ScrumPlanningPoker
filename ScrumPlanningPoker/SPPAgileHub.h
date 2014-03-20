//
//  SPPAgileHub.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalR.h"
#import "SPPRoom.h"

@protocol SPPAgileHubRoomDelegate<NSObject>
//@required
@optional
- (void)onJoinRoom: (SPPRoom *)room;
- (void)onDidJoinRoom: (struct SPPRoomResult) roomResult;
@end


@interface SPPAgileHub : NSObject

@property (nonatomic, assign)id <SPPAgileHubRoomDelegate> roomDelegate;
@property (readonly) SRHubConnection *hubConnection;
@property (readonly) SRHubProxy *hub;
@property NSString *sessionId;

+ (instancetype) SPPAgileHubWithHubConnection: (SRHubConnection *) initHubConnection;
- (instancetype) initWithHubConnection:(SRHubConnection *) initHubConnection;

- (void) JoinRoom: (NSString *) roomName;

@end
