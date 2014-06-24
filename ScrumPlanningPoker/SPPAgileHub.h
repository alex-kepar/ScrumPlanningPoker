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
#import "SPPUser.h"

@class SPPAgileHub;
@protocol SPPAgileHubRoomDelegate<NSObject>
//@required
@optional
- (void)agileHubJoinRoom: (SPPRoom *) room;
- (void)agileHubJoinUser: (SPPUser *) user toRoom: (SPPRoom *) room;
- (void)agileHubLeftUser: (SPPUser *) user theRoom: (SPPRoom *) room;
- (void)agileHubRoomChanged: (SPPRoom *) room;
@end

@protocol SPPAgileHubConnectionDelegate<NSObject>
//@required
@optional
- (void)agileHubDidOpen:(SPPAgileHub *) agileHub;
- (void)agileHub:(SPPAgileHub *) agileHub didReceiveError:(NSString *)error;
@end


@interface SPPAgileHub : NSObject <SRConnectionDelegate>

@property (nonatomic, assign)id <SPPAgileHubRoomDelegate> roomDelegate;
@property (nonatomic, assign)id <SPPAgileHubConnectionDelegate> connectionDelegate;
//@property (strong, nonatomic, readwrite) SRHubConnection *hubConnection;
//@property (strong, nonatomic, readwrite) SRHubProxy *hub;
@property NSString *sessionId;

//+ (instancetype) SPPAgileHubWithHubConnection: (SRHubConnection *) initHubConnection;
//- (instancetype) initWithHubConnection:(SRHubConnection *) initHubConnection;

- (void) ConnectTo:(NSString *) server;
- (void) Disconnect;

- (void) joinRoom: (NSString *) roomName;
- (void) leaveRoom: (NSString *) roomName;
@end
