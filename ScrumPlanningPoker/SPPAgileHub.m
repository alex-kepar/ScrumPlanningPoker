//
//  SPPAgileHub.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPAgileHub.h"
#import "SPPProperties.h"
#import "SRVersion.h"

@implementation SPPAgileHub
{
    SRHubConnection *hubConnection;
    SRHubProxy *hub;
}

@synthesize roomDelegate;
@synthesize connectionDelegate;

//@synthesize hubConnection;
//@synthesize hub;
@synthesize sessionId;



/*+ (instancetype) SPPAgileHubWithHubConnection: (SRHubConnection*) initHubConnection
{
    return [[self alloc] initWithHubConnection:initHubConnection];
}

- (instancetype)initWithHubConnection:(SRHubConnection *) initHubConnection
{
    self = [super init];
    if (self)
    {
        hubConnection = initHubConnection;
        hub = [hubConnection createHubProxy:@"agileHub"];
        // Connection events
        [hub on:@"onUserLogged" perform:self selector:@selector(onUserLogged:)];
        [hub on:@"onState" perform:self selector:@selector(onState:)];
        [hub on:@"onErrorHandler" perform:self selector:@selector(onErrorHandler:)];
        // Room events
        [hub on:@"onInitRoom" perform:self selector:@selector(onInitRoom:)];
        [hub on:@"onJoinedRoom" perform:self selector:@selector(onJoinedRoom:)];
        [hub on:@"onLeftRoom" perform:self selector:@selector(onLeftRoom:)];
        [hub on:@"onRoomStateChanged" perform:self selector:@selector(onRoomStateChanged:)];
    }
    return self;
}
*/

- (void) Disconnect
{
    if (hubConnection) {
        [hubConnection stop];
        [hubConnection disconnect];
        hubConnection = Nil;
    }
}

- (void) ConnectTo:(NSString *) server
{
    [self Disconnect];
    
    hubConnection = [SRHubConnection connectionWithURL:[NSString stringWithFormat:@"http://%@", server]];
    [hubConnection setProtocol:[[SRVersion alloc] initWithMajor:1 minor: 2]];
    //[hubConnection setReceived:(onReceived)received]
    hubConnection.received = ^(NSString * dataReceived){
        NSLog(@"***********************************\n***********************************\nData received:\n%@", dataReceived);
    };
    //[hubConnection addValue:[NSString stringWithFormat:@".ASPXAUTH=%@", properties.userToken] forHTTPHeaderField:@"Cookie"];
    
//    properties.agileHub = [SPPAgileHub SPPAgileHubWithHubConnection:hubConnection];
//    properties.hubConnection=hubConnection;
    
    hub = [hubConnection createHubProxy:@"agileHub"];
    // Connection events
    [hub on:@"onUserLogged" perform:self selector:@selector(onUserLogged:)];
    [hub on:@"onState" perform:self selector:@selector(onState:)];
    [hub on:@"onErrorHandler" perform:self selector:@selector(onErrorHandler:)];
    // Room events
    [hub on:@"onInitRoom" perform:self selector:@selector(onInitRoom:)];
    [hub on:@"onJoinedRoom" perform:self selector:@selector(onJoinedRoom:)];
    [hub on:@"onLeftRoom" perform:self selector:@selector(onLeftRoom:)];
    [hub on:@"onRoomStateChanged" perform:self selector:@selector(onRoomStateChanged:)];
    
    [hubConnection setDelegate:self];
    [hubConnection start];
}


#pragma mark + SRConnection Delegate
- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    NSLog(@"***** SRConnectionDidOpen invoked");
    //[self unLockView];
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{
    NSLog(@"***** SRConnection did receive data invoked Data:\n%@", data);
    //[messagesReceived insertObject:[MessageItem messageItemWithUserName:@"Connection did recieve data" Message:@""] atIndex:0];
    //[tvMessages reloadData];
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
    NSLog(@"***** SRConnectionDidClose invoked");
}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{
    NSLog(@"***** SRConnection did receive error invoked");
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHub:didReceiveError:)])
    {
        [connectionDelegate agileHub:self didReceiveError:[NSString stringWithFormat:@"%@", [error localizedDescription]]];
    }
}
#pragma mark - SRConnection Delegate

- (void)onUserLogged: (NSDictionary *) userDto
{
    [SPPProperties sharedProperties].user = [SPPUser SPPUserWithDataDictionary:userDto];
    NSLog(@"***** onUserLogged Data:\n%@", userDto);
}

- (void)onState: (NSDictionary *) state
{
    NSLog(@"***** onState Data:\n%@", state);
    sessionId = [state objectForKey:@"SessionId"];
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHubDidOpen:)])
    {
        [connectionDelegate agileHubDidOpen:self];
    }
}

-(void)onErrorHandler: (NSDictionary *) messageDto
{
    NSLog(@"***** onErrorHandler\nmessage:\n%@", messageDto);
}

-(void)onInitRoom: (NSDictionary *) roomDto
{
    NSLog(@"***** onInitRoom Data:\n%@", roomDto);
    SPPRoom* initRoom=[SPPRoom SPPRoomWithDataDictionary:roomDto];
    NSMutableArray *roomList = [SPPProperties sharedProperties].roomList;
    NSInteger idx = [roomList indexOfObjectPassingTest:^BOOL(SPPRoom* item, NSUInteger idx, BOOL *stop) {
        return (item.roomId == initRoom.roomId);
    }];
    if (idx == NSNotFound) {
        [roomList addObject:initRoom];
    } else {
        [[roomList objectAtIndex:idx] updateFromRoom:initRoom];
        initRoom = [roomList objectAtIndex:idx];
    }
    [SPPProperties sharedProperties].room = initRoom;
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubJoinRoom:)])
    {
        [roomDelegate agileHubJoinRoom:initRoom];
    }
}

-(void)onJoinedRoom: (NSDictionary *) userDto
{
    NSLog(@"***** onJoinedRoom Data:\n%@", userDto);
    SPPUser * joinedUser = [SPPUser SPPUserWithDataDictionary:userDto];
    SPPRoom * room = [SPPProperties sharedProperties].room;
    [room.connectedUsers addObject:joinedUser];
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubJoinUser:toRoom:)]) {
        [roomDelegate agileHubJoinUser:joinedUser toRoom:room];
    }
}

-(void)onLeftRoom: (NSDictionary *) userDto
{
    NSLog(@"***** onLeftRoom Data:\n%@", userDto);
    SPPUser * leftUser = [SPPUser SPPUserWithDataDictionary:userDto];
    SPPRoom * room = [SPPProperties sharedProperties].room;
    //NSMutableArray* connectedUsers = room.connectedUsers;
    NSInteger idx = [room.connectedUsers indexOfObjectPassingTest:^BOOL(SPPUser* user, NSUInteger idx, BOOL *stop) {
        return (user.userId == leftUser.userId);
    }];
    if (idx != NSNotFound) {
        [room.connectedUsers removeObjectAtIndex:idx];
        if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubLeftUser:theRoom:)]) {
            [roomDelegate agileHubLeftUser:leftUser theRoom:room];
        }
    }
}

-(void)onRoomStateChanged: (NSDictionary *) roomDto
{
    NSLog(@"***** onRoomStateChanged Data:\n%@", roomDto);
    SPPRoom* room=[SPPRoom SPPRoomWithDataDictionary:roomDto];
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubRoomChanged:)]) {
        [roomDelegate agileHubRoomChanged:room];
    }

    
    //NSInteger idx = [room.connectedUsers indexOfObjectPassingTest:^BOOL(SPPUser* user, NSUInteger idx, BOOL *stop) {
    //    return (user.userId == leftUser.userId);
    //}];

    
/*    SPPRoom* room=[SPPRoom SPPRoomWithDataDictionary:roomDto];
    [SPPProperties sharedProperties].room = room;
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubJoinRoom:)])
    {
        [roomDelegate agileHubJoinRoom:room];
    }

    
    NSLog(@"***** onLeftRoom Data:\n%@", userDto);
    SPPUser * leftUser = [SPPUser SPPUserWithDataDictionary:userDto];
    SPPRoom * room = [SPPProperties sharedProperties].room;
    //NSMutableArray* connectedUsers = room.connectedUsers;
    NSInteger idx = [room.connectedUsers indexOfObjectPassingTest:^BOOL(SPPUser* user, NSUInteger idx, BOOL *stop) {
        return (user.userId == leftUser.userId);
    }];
    if (idx != NSNotFound) {
        [room.connectedUsers removeObjectAtIndex:idx];
        if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubLeftUser:theRoom:)]) {
            [roomDelegate agileHubLeftUser:leftUser theRoom:room];
        }
    }*/
}

- (void) joinRoom: (NSString *) roomName
{
    [hub   invoke:@"JoinRoom"
         withArgs:@[roomName, sessionId]];
}

- (void) leaveRoom: (NSString *) roomName
{
    [hub   invoke:@"LeaveRoom"
         withArgs:@[roomName, sessionId]];
}
     
@end
