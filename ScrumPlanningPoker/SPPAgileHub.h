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
- (void)agileHub: (SPPAgileHub *) agileHub ConnectionDidOpen:(SRConnection *) connection;
- (void)agileHub: (SPPAgileHub *) agileHub ConnectionDidClose:(SRConnection *) connection;
- (void)agileHub: (SPPAgileHub *) agileHub Connection:(SRConnection *) connection didReceiveError:(NSError *)error;
@end

@interface SPPAgileHub : NSObject <SRConnectionDelegate>

@property (nonatomic, assign)id <SPPAgileHubConnectDelegate> connectDelegate;

@property NSString *sessionId;

- (void) ConnectTo:(NSString *) server;
- (void) Disconnect;

- (void)joinRoom:(NSString*)roomName;
- (void)leaveRoom:(NSString*)roomName;

- (void)room:(NSString*)roomName withVote:(NSInteger)voteId doVote:(NSInteger)voteValue;
- (void)room:(NSString*)roomName openVote:(NSInteger)voteId;
- (void)room:(NSString*)roomName closeVote:(NSInteger)voteId withOveralValue:(NSInteger)overalValue;
- (void)room:(NSString*)roomName changeState:(BOOL)newState;

@end
