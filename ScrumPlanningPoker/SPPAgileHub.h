//
//  SPPAgileHub.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalR.h"

@class SPPAgileHub;
@protocol SPPAgileHubConnectDelegate<NSObject>
@optional
- (void)agileHubDidOpen:(SPPAgileHub *) agileHub;
- (void)agileHubDidClose:(SPPAgileHub *) agileHub;
- (void)agileHub:(SPPAgileHub *) agileHub didLogUser:(NSDictionary *)userData;
- (void)agileHub:(SPPAgileHub *) agileHub didReceiveError:(NSString *)error;
@end

@protocol SPPAgileHubStateDelegate<NSObject>
@optional
- (void)agileHubDidChangeState: (NSDictionary *) roomData;
- (void)agileHubDidOpenRoom: (NSDictionary *) roomData;
@end

@protocol SPPAgileHubRoomDelegate<NSObject>
@optional
- (void)agileHubDidJoinUser: (NSDictionary *) userData;
- (void)agileHubDidLeaveUser: (NSDictionary *) userData;
- (void)agileHubDidChangeRoom: (NSDictionary *) roomData;
@end

@protocol SPPAgileHubVoteDelegate<NSObject>
@optional
- (void)agileHubDidUserVote: (NSDictionary *) userVoteData;
- (void)agileHubDidVoteFinish: (NSDictionary *) voteData;
- (void)agileHubDidVoteOpen: (NSDictionary *) voteData;
- (void)agileHubDidVoteClose: (NSDictionary *) voteData;
@end

@interface SPPAgileHub : NSObject <SRConnectionDelegate>

@property (nonatomic, assign)id <SPPAgileHubConnectDelegate> connectDelegate;
@property (nonatomic, assign)id <SPPAgileHubStateDelegate> stateDelegate;
@property (nonatomic, assign)id <SPPAgileHubRoomDelegate> roomDelegate;
@property (nonatomic, assign)id <SPPAgileHubVoteDelegate> voteDelegate;

@property NSString *sessionId;

- (void) ConnectTo:(NSString *) server;
- (void) Disconnect;

- (void) joinRoom: (NSString *) roomName;
- (void) leaveRoom: (NSString *) roomName;

- (void) vote: (NSInteger) voteId doVote: (NSInteger) voteValue forRooom: (NSString *) roomName;

@end
