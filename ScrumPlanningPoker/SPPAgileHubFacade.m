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
    SPPRoom *openedRoom;
}

//@synthesize delegate;

+ (instancetype) SPPAgileHubFacadeWithAgileHub:(SPPAgileHub*)initAgileHub roomList:(NSArray*)initRoomList {
    return [[self alloc] initWithAgileHub:initAgileHub roomList:initRoomList];
}

- (NSArray *) rooms {
    return roomList;
}

- (SPPRoom*) openedRoom {
    return openedRoom;
}

- (instancetype) initWithAgileHub:(SPPAgileHub*)initAgileHub roomList:(NSArray*)initRoomList {
    if (self = [super init]) {
        roomList = [NSMutableArray arrayWithCapacity:initRoomList.count];
        for (int i = 0; i < initRoomList.count; i++) {
            if ([initRoomList[i] isKindOfClass:[NSDictionary class]]) {
                [roomList addObject:[self _createRoomUseData:initRoomList[i]]];
            }
        }

        agileHub = initAgileHub;

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
-(void) notifyAgileHubRoom_onOpened:(NSNotification*) notification {
    openedRoom = [self _synchronizeRoomUseData:notification.userInfo[@"roomDto"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubFacade_onDidOpenRoom
                                                        object:self
                                                      userInfo:@{@"room": openedRoom}];
    //if (delegate && [delegate respondsToSelector:@selector(SPPAgileHubFacade:DidOpenRoom:)]) {
    //    [delegate SPPAgileHubFacade:self DidOpenRoom:openedRoom];
    //}
}

-(void) notifyAgileHubRoom_Changed:(NSNotification*) notification {
    [self _synchronizeRoomUseData:notification.userInfo[@"roomDto"]];
}

-(void) notifyAgileHubRoom_onUserJoined:(NSNotification*) notification {
    if (openedRoom != nil) {
        [openedRoom updateUser:notification.userInfo[@"userDto"]];
    }
}

-(void) notifyAgileHubRoom_onUserLeft:(NSNotification*) notification {
    if (openedRoom != nil) {
        [openedRoom removeUser:notification.userInfo[@"userDto"]];
    }
}

-(void) notifyAgileHubRoom_onUserVoted:(NSNotification*) notification {
    if (openedRoom != nil) {
        [openedRoom userVote:notification.userInfo[@"userVoteDto"]];
    }
}

-(void) notifyAgileHubRoom_UpdateVote:(NSNotification*) notification {
    if (openedRoom != nil) {
        [openedRoom updateVote:notification.userInfo[@"voteDto"]];
    }
}

// methods
- (void) openRoomUseIndex:(NSInteger)roomIndex {
    if (roomIndex < roomList.count) {
        [self openRoomUseName:[roomList[roomIndex] name]];
    }
}

- (void) openRoomUseName: (NSString*)roomName {
    if (openedRoom != nil) {
        [self closeRoom];
    }
    [agileHub joinRoom:roomName];
}

- (void) closeRoom {
    if (openedRoom != nil) {
        [agileHub leaveRoom:openedRoom.name];
        openedRoom = nil;
    }
}

- (void) vote:(NSInteger)voteId doVote:(NSInteger)voteValue {
    if (openedRoom != nil) {
        [agileHub room:openedRoom.name
              withVote:voteId
                doVote:voteValue];
    }
}

// SPPRoomDelegate
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

// internal methods:
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

@end
