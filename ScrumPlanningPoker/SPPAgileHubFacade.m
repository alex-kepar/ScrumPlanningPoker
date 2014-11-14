//
//  SPPAgileHubFacade.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/11/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPAgileHubFacade.h"
#import "SPPAgileHubNotifications.h"

NSString *const SPPAgileHubFacade_onChanged = @"SPPAgileHubFacade_onChanged";
NSString *const SPPAgileHubFacade_onDidOpenRoom = @"SPPAgileHubFacade_onDidOpenRoom";

@implementation SPPAgileHubFacade {
    NSMutableArray *roomList;
    SPPAgileHub *agileHub;
}

- (NSArray *) rooms {
    return roomList;
}
@synthesize connectionDelegate;
@synthesize webService;
@synthesize currentUser;
@synthesize openedRoom;

+ (instancetype) SPPAgileHubFacadeWithRoomList:(NSArray*)initRoomList andWebService:(SPPWebService*)initWebService {
//+ (instancetype) SPPAgileHubFacadeWithRoomList:(NSArray*)initRoomList serverName:(NSString*)initServerName {
    return [[self alloc] initWithRoomList:initRoomList andWebService:initWebService];
}

- (instancetype) initWithRoomList:(NSArray*)initRoomList andWebService:(SPPWebService*)initWebService {
///- (instancetype) initWithRoomList:(NSArray*)initRoomList serverName:(NSString*)initServerName {
    if (self = [super init]) {
        roomList = [NSMutableArray arrayWithCapacity:initRoomList.count];
        for (int i = 0; i < initRoomList.count; i++) {
            if ([initRoomList[i] isKindOfClass:[NSDictionary class]]) {
                [roomList addObject:[self _createRoomUseData:initRoomList[i]]];
            }
        }

        webService = initWebService;
        agileHub = [[SPPAgileHub alloc] init];
        agileHub.connectionDelegate = self;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHub_Connected:)
                                                     name:SPPAgileHub_onConnected
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHub_ErrorCatched:)
                                                     name:SPPAgileHub_onErrorCatched
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHub_UserLogged:)
                                                     name:SPPAgileHub_onUserLogged
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHubRoom_Changed:)
                                                     name:SPPAgileHub_onRoomChanged
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHubRoom_onOpened:)
                                                     name:SPPAgileHubRoom_onOpened
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHubRoom_Changed:)
                                                     name:SPPAgileHubRoom_onChanged
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHubRoom_onUserJoined:)
                                                     name:SPPAgileHubRoom_onUserJoined
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHubRoom_onUserLeft:)
                                                     name:SPPAgileHubRoom_onUserLeft
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHubRoom_onUserVoted:)
                                                     name:SPPAgileHubRoom_onUserVoted
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHubRoom_UpdateVote:)
                                                     name:SPPAgileHubRoom_onVoteFinished
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHubRoom_UpdateVote:)
                                                     name:SPPAgileHubRoom_onVoteOpened
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAgileHubRoom_UpdateVote:)
                                                     name:SPPAgileHubRoom_onVoteClosed
                                                   object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"********** SPPAgileHubFacade deallocated.");
}

// notify handling
-(void) notifyAgileHub_Connected:(NSNotification*) notification {
    NSDictionary *sessionDto = notification.userInfo[@"sessionDto"];
    NSInteger userId = [[sessionDto valueForKey:@"UserId"] integerValue];
    if (userId != currentUser.entityId) {
        currentUser = nil;
        if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHubFacade:HubDidReceiveError:)]) {
            NSDictionary *errorDetail = [NSDictionary dictionaryWithObject:@"Id o the logged user does not correspond to the connected users's Id." forKey:NSLocalizedDescriptionKey];
            NSError *error=[NSError errorWithDomain:@"SPPAgileHubFacade" code:-100 userInfo:errorDetail];
            __weak SPPAgileHubFacade *weakSelf = self;
            [connectionDelegate agileHubFacade:weakSelf HubDidReceiveError:error];
        }
    } else {
        if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHubFacade:HubSessionDidOpenByUser:)]) {
            __weak SPPAgileHubFacade *weakSelf = self;
            [connectionDelegate agileHubFacade:weakSelf HubSessionDidOpenByUser:currentUser];
        }
    }
}

-(void) notifyAgileHub_ErrorCatched:(NSNotification*) notification {
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHubFacade:HubDidReceiveError:)]) {
        NSDictionary *errorDetail = [NSDictionary dictionaryWithObject:notification.userInfo[@"messageDto"] forKey:NSLocalizedDescriptionKey];
        NSError *error=[NSError errorWithDomain:@"SPPAgileHubFacade" code:-101 userInfo:errorDetail];
        __weak SPPAgileHubFacade *weakSelf = self;
        [connectionDelegate agileHubFacade:weakSelf HubDidReceiveError:error];
    }
}

-(void) notifyAgileHub_UserLogged:(NSNotification*) notification {
    currentUser = [SPPUser SPPBaseEntityWithDataDictionary:notification.userInfo[@"userDto"]];
}

-(void) notifyAgileHubRoom_onOpened:(NSNotification*) notification {
    openedRoom = [self _synchronizeRoomUseData:notification.userInfo[@"roomDto"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubFacade_onDidOpenRoom
                                                        object:self
                                                      userInfo:@{@"room": openedRoom}];
}

-(void) notifyAgileHubRoom_Changed:(NSNotification*) notification {
    [self _synchronizeRoomUseData:notification.userInfo[@"roomDto"]];
}

-(void) notifyAgileHubRoom_onUserJoined:(NSNotification*) notification {
    if (openedRoom) {
        [openedRoom didUpdateUser:notification.userInfo[@"userDto"]];
    }
}

-(void) notifyAgileHubRoom_onUserLeft:(NSNotification*) notification {
    if (openedRoom) {
        [openedRoom didRemoveUser:notification.userInfo[@"userDto"]];
    }
}

-(void) notifyAgileHubRoom_onUserVoted:(NSNotification*) notification {
    if (openedRoom) {
        [openedRoom didUserVote:notification.userInfo[@"userVoteDto"]];
    }
}

-(void) notifyAgileHubRoom_UpdateVote:(NSNotification*) notification {
    if (openedRoom) {
        [openedRoom didUpdateVote:notification.userInfo[@"voteDto"]];
    }
}

#pragma mark - methods
- (void) openRoomUseIndex:(NSInteger)roomIndex {
    if (roomIndex < roomList.count) {
        [self openRoomUseName:[roomList[roomIndex] name]];
    }
}

- (void) openRoomUseName: (NSString*)roomName {
    if (openedRoom) {
        [self closeRoom];
    }
    [agileHub joinRoom:roomName];
}

- (void) closeRoom {
    if (openedRoom) {
        [agileHub leaveRoom:openedRoom.name];
        openedRoom = nil;
    }
}

- (void) vote:(NSInteger)voteId doVote:(NSInteger)voteValue {
    if (openedRoom) {
        [agileHub room:openedRoom.name
              withVote:voteId
                doVote:voteValue];
    }
}

#pragma mark - SPPRoomDelegate
- (void) SPPRoom:(SPPRoom *) room withVote: (SPPVote*) vote doVote: (NSInteger) voteValue {
    [agileHub room:room.name
          withVote:vote.entityId
            doVote:voteValue];
}

- (void)SPPRoom:(SPPRoom*)room openVote:(SPPVote*)vote {
    [agileHub room:room.name
          openVote:vote.entityId];
}

- (void)SPPRoom:(SPPRoom*)room closeVote:(SPPVote*)vote withOveralValue:(NSInteger)overalValue {
    [agileHub room:room.name
         closeVote:vote.entityId
   withOveralValue:overalValue];
}

- (void)SPPRoom:(SPPRoom *)room changeState:(BOOL)newState {
    [agileHub room:room.name
         changeState:newState];
}

- (void)SPPRoom:(SPPRoom *)room removeUser:(SPPUser *)user {
    [webService removeUser:user.entityId
                  fromRoom:room.entityId];
}

- (void)SPPRoom:(SPPRoom *)room addVoteWithContent:(NSString*)voteContent {
    [agileHub room:room.name
addVoteWithContent:voteContent];
}

- (void)SPPRoom:(SPPRoom *)room removeVote:(SPPVote *)vote {
    [agileHub room:room.name
        removeVote:vote.entityId];
}

#pragma mark - internal methods:
- (SPPRoom*) _createRoomUseData:(NSDictionary*) roomDto {
    SPPRoom *room = [SPPRoom SPPBaseEntityWithDataDictionary:roomDto];
    room.roomDelegate = self;
    return room;
}

- (SPPRoom*) _synchronizeRoomUseData:(NSDictionary *) roomDto {
    NSInteger entityId = [[roomDto objectForKey:@"Id"] integerValue];
    NSInteger idx = [roomList indexOfObjectPassingTest:^BOOL(SPPRoom* roomItem, NSUInteger idx, BOOL *stop) {
        return (roomItem.entityId == entityId);
    }];
    SPPRoom *room;
    if (idx != NSNotFound) {
        room = roomList[idx];
        [room updateFromDictionary:roomDto];
    }
    else {
        room = [self _createRoomUseData:roomDto];
        [roomList addObject:room];
        [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubFacade_onChanged
                                                            object:self
                                                          userInfo:@{@"list": roomList}];
    }
    return room;
}

#pragma mark - connection block
- (void) connect {
    [agileHub ConnectTo:webService.server];
}

- (void) disconnect {
    [agileHub Disconnect];
}

#pragma mark - SPPAgileHubConnectDelegate
- (void)agileHub: (SPPAgileHub *) agileHub ConnectionDidClose:(SRConnection *) connection {
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHubFacade:ConnectionDidClose:)])
    {
        __weak SPPAgileHubFacade *weakSelf = self;
        [connectionDelegate agileHubFacade:weakSelf ConnectionDidClose:connection];
    }

}

- (void)agileHub: (SPPAgileHub *) agileHub ConnectionDidOpen:(SRConnection *) connection {
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHubFacade:ConnectionDidOpen:)]) {
        __weak SPPAgileHubFacade *weakSelf = self;
        [connectionDelegate agileHubFacade:weakSelf ConnectionDidOpen:connection];
    }
}

- (void)agileHub: (SPPAgileHub *) agileHub Connection:(SRConnection *) connection didReceiveError:(NSError *)error {
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHubFacade:Connection:didReceiveError:)]) {
        __weak SPPAgileHubFacade *weakSelf = self;
        [connectionDelegate agileHubFacade:weakSelf Connection:connection didReceiveError:error];
    }
}

@end
