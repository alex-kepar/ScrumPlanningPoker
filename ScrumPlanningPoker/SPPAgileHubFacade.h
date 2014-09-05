//
//  SPPAgileHubFacade.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/11/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPAgileHub.h"
#import "SPPRoom.h"
#import "SPPUser.h"

@class SPPAgileHubFacade;

FOUNDATION_EXPORT NSString *const SPPAgileHubFacade_onChanged;
FOUNDATION_EXPORT NSString *const SPPAgileHubFacade_onDidOpenRoom;


@protocol SPPAgileHubFacadeConnectionDelegate<NSObject>
@optional
- (void)agileHubFacade:(SPPAgileHubFacade*)hub ConnectionDidOpen:(SRConnection*)connection;
- (void)agileHubFacade:(SPPAgileHubFacade*)hub ConnectionDidClose:(SRConnection*)connection;
- (void)agileHubFacade:(SPPAgileHubFacade*)hub Connection:(SRConnection*)connection didReceiveError:(NSError*)error;
- (void)agileHubFacade:(SPPAgileHubFacade*)hub HubSessionDidOpenByUser:(SPPUser*)user;
- (void)agileHubFacade:(SPPAgileHubFacade*)hub HubDidReceiveError:(NSError*)error;
@end

@interface SPPAgileHubFacade : NSObject <SPPRoomDelegate, SPPAgileHubConnectionDelegate>

@property (nonatomic, weak)id <SPPAgileHubFacadeConnectionDelegate> connectionDelegate;

@property NSString *serverName;
@property (readonly) SPPUser *currentUser;
@property (readonly) NSArray *rooms;
@property (readonly) SPPRoom *openedRoom;

+ (instancetype) SPPAgileHubFacadeWithRoomList:(NSArray*)initRoomList serverName:(NSString*)initServerName;
- (instancetype) initWithRoomList:(NSArray*)initRoomList serverName:(NSString*)initServerName;

- (void) connect;
- (void) disconnect;

- (void) openRoomUseIndex:(NSInteger)roomIndex;
- (void) openRoomUseName:(NSString*)roomName;
- (void) closeRoom;

@end
