//
//  SPPAgileHub.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPAgileHub.h"
#import "SRVersion.h"

@implementation SPPAgileHub
{
    SRHubConnection *hubConnection;
    SRHubProxy *hub;
}

@synthesize sessionId;
@synthesize connectDelegate;
@synthesize stateDelegate;
@synthesize roomDelegate;
//@synthesize voteDelegate;

- (void) Disconnect
{
    if (hubConnection) {
        [hubConnection stop];
        [hubConnection disconnect];
        hubConnection = nil;
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

    hub = [hubConnection createHubProxy:@"agileHub"];
    // Connection events
    [hub on:@"onUserLogged" perform:self selector:@selector(onUserLogged:)];
    [hub on:@"onState" perform:self selector:@selector(onState:)];
    [hub on:@"onHubStateChanged" perform:self selector:@selector(onHubStateChanged:)];
    [hub on:@"onErrorHandler" perform:self selector:@selector(onErrorHandler:)];
    // Room events
    [hub on:@"onInitRoom" perform:self selector:@selector(onInitRoom:)];
    [hub on:@"onJoinedRoom" perform:self selector:@selector(onJoinedRoom:)];
    [hub on:@"onLeftRoom" perform:self selector:@selector(onLeftRoom:)];
    [hub on:@"onRoomStateChanged" perform:self selector:@selector(onRoomStateChanged:)];
    // Vote events
    [hub on:@"onUserVoted" perform:self selector:@selector(onUserVoted:)];
    [hub on:@"onVoteFinished" perform:self selector:@selector(onVoteFinished:)];
    [hub on:@"onVoteItemOpened" perform:self selector:@selector(onVoteItemOpened:)];
    [hub on:@"onVoteItemClosed" perform:self selector:@selector(onVoteItemClosed:)];
    
    [hubConnection setDelegate:self];
    [hubConnection start];
}


#pragma mark + SRConnection Delegate & SPPAgileHubConnectDelegate
- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    NSLog(@"***** SRHubConnectionDidOpen invoked");
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{
    NSLog(@"***** SRHubConnection did receive data invoked Data:\n%@", data);
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
    NSLog(@"***** SRHubConnectionDidClose invoked");
    if (connectDelegate && [connectDelegate respondsToSelector:@selector(agileHubDidClose:)])
    {
        [connectDelegate agileHubDidClose:self];
    }
}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{
    NSLog(@"***** SRHubConnection did receive error invoked");
    if (connectDelegate && [connectDelegate respondsToSelector:@selector(agileHub:didReceiveError:)])
    {
        [connectDelegate agileHub:self didReceiveError:[NSString stringWithFormat:@"%@", [error localizedDescription]]];
    }
}

- (void)onUserLogged: (NSDictionary *) userDto
{
    NSLog(@"***** onUserLogged Data:\n%@", userDto);
    if (connectDelegate && [connectDelegate respondsToSelector:@selector(agileHub:didLogUser:)])
    {
        [connectDelegate agileHub:self didLogUser:userDto];
    }
}

- (void)onState: (NSDictionary *) state
{
    // invoked after onUserLogged and indicate - connection is ok
    NSLog(@"***** onState Data:\n%@", state);
    sessionId = [state objectForKey:@"SessionId"];
    if (connectDelegate && [connectDelegate respondsToSelector:@selector(agileHubDidOpen:)])
    {
        [connectDelegate agileHubDidOpen:self];
    }
}

-(void)onErrorHandler: (NSDictionary *) messageDto
{
    NSLog(@"***** onErrorHandler\nmessage:\n%@", messageDto);
    if (connectDelegate && [connectDelegate respondsToSelector:@selector(agileHub:didReceiveError:)])
    {
        [connectDelegate agileHub:self didReceiveError:[NSString stringWithFormat: @"%@", messageDto]];
    }
}
#pragma mark - SRConnection Delegate & SPPAgileHubConnectDelegate

#pragma mark + SPPAgileHubRoomMethodsDelegate
- (void) SPPAgileHubRoom:(NSString *) roomName vote: (NSInteger) voteId doVote: (NSInteger) voteValue {
    
}
#pragma mark - SPPAgileHubRoomMethodsDelegate

#pragma mark + SPPAgileHubStateDelegate
-(void)onHubStateChanged: (NSDictionary *) roomDto
{
    NSLog(@"***** onHubStateChanged Data:\n%@", roomDto);
    if (stateDelegate && [stateDelegate respondsToSelector:@selector(agileHubDidChangeState:)]) {
        [stateDelegate agileHubDidChangeState:roomDto];
    }
}

-(void)onInitRoom: (NSDictionary *) roomDto
{
    NSLog(@"***** onInitRoom Data:\n%@", roomDto);
    if (stateDelegate && [stateDelegate respondsToSelector:@selector(agileHubDidOpenRoom:)])
    {
        [stateDelegate agileHubDidOpenRoom:roomDto];
    }
}
#pragma mark - SPPAgileHubStateDelegate

#pragma mark + SPPAgileHubRoomDelegate
-(void)onJoinedRoom: (NSDictionary *) userDto
{
    NSLog(@"***** onJoinedRoom Data:\n%@", userDto);
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubDidJoinUser:)]) {
        [roomDelegate agileHubDidJoinUser:userDto];
    }
}

-(void)onLeftRoom: (NSDictionary *) userDto
{
    NSLog(@"***** onLeftRoom Data:\n%@", userDto);
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubDidLeaveUser:)]) {
        [roomDelegate agileHubDidLeaveUser:userDto];
    }
    //}
}

-(void)onRoomStateChanged: (NSDictionary *) roomDto
{
    NSLog(@"***** onRoomStateChanged Data:\n%@", roomDto);
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubDidChangeRoom:)]) {
        [roomDelegate agileHubDidChangeRoom:roomDto];
    }
}
#pragma mark - SPPAgileHubRoomDelegate


-(void)onUserVoted: (NSDictionary *) userVoteDto
{
    NSLog(@"***** onUserVoted Data:\n%@", userVoteDto);
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubDidUserVote:)]) {
        [roomDelegate agileHubDidUserVote:userVoteDto];
    }
}

-(void)onVoteFinished: (NSDictionary *) voteDto
{
    NSLog(@"***** onVoteFinished Data:\n%@", voteDto);
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubDidVoteFinish:)]) {
        [roomDelegate agileHubDidVoteFinish:voteDto];
    }
}

-(void)onVoteItemOpened: (NSDictionary *) voteDto
{
    NSLog(@"***** onVoteItemOpened Data:\n%@", voteDto);
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubDidVoteOpen:)]) {
        [roomDelegate agileHubDidVoteOpen:voteDto];
    }
}

-(void)onVoteItemClosed: (NSDictionary *) voteDto
{
    NSLog(@"***** onVoteItemClosed Data:\n%@", voteDto);
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(agileHubDidVoteClose:)]) {
        [roomDelegate agileHubDidVoteClose:voteDto];
    }
}

- (void) joinRoom: (NSString *) roomName {
    [hub   invoke:@"JoinRoom"
         withArgs:@[roomName, sessionId]];
}

- (void) leaveRoom: (NSString *) roomName {
    [hub   invoke:@"LeaveRoom"
         withArgs:@[roomName, sessionId]];
}

- (void) room: (NSString *) roomName withVote: (NSInteger) voteId doVote: (NSInteger) voteValue {
    [hub   invoke:@"VoteForItem"
         withArgs:@[roomName, [NSString stringWithFormat:@"%d", voteId], [NSString stringWithFormat:@"%d", voteValue]]];
}

@end
