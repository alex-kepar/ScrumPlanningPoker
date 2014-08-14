//
//  SPPAgileHub.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPAgileHub.h"
#import "SRVersion.h"
#import "SPPAgileHubNotifications.h"

@implementation SPPAgileHub
{
    SRHubConnection *hubConnection;
    SRHubProxy *hub;
}

@synthesize sessionId;
@synthesize connectDelegate;

- (void) Disconnect
{
    if (hubConnection) {
        [hubConnection stop];
        [hubConnection disconnect];
        hubConnection = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) ConnectTo:(NSString *) server
{
    [self Disconnect];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notify_JoinRoom:)
                                                 name:SPPAgileHub_JoinRoom
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notify_LeaveRoom:)
                                                 name:SPPAgileHub_LeaveRoom
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notify_Vote:)
                                                 name:SPPAgileHub_Vote
                                               object:nil];
    
    hubConnection = [SRHubConnection connectionWithURL:[NSString stringWithFormat:@"http://%@", server]];
    [hubConnection setProtocol:[[SRVersion alloc] initWithMajor:1 minor: 2]];
    //[hubConnection setReceived:(onReceived)received]
    //hubConnection.received = ^(NSString * dataReceived){
    //    NSLog(@"***********************************\n***********************************\nData received:\n%@", dataReceived);
    //};

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

#pragma mark + SRConnection Delegate retranslate to SPPAgileHubConnectDelegate
- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    if (connectDelegate && [connectDelegate respondsToSelector:@selector(agileHub:ConnectionDidOpen:)])
    {
        [connectDelegate agileHub:self ConnectionDidOpen:connection];
    }
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{
    NSLog(@"***** SRHubConnection did receive data invoked Data:\n%@", data);
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
    if (connectDelegate && [connectDelegate respondsToSelector:@selector(agileHub:ConnectionDidClose:)])
    {
        [connectDelegate agileHub:self ConnectionDidClose:connection];
    }
}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{
    if (connectDelegate && [connectDelegate respondsToSelector:@selector(agileHub:Connection:didReceiveError:)])
    {
        [connectDelegate agileHub:self Connection:connection didReceiveError:error];
    }
}
#pragma mark - SRConnection Delegate

#pragma mark + event notitifocations
- (void)onUserLogged: (NSDictionary *) userDto
{
    //[{"H":"agileHub","M":"onUserLogged","A":[{"Name":"Admin","IsAdmin":true,"Privileges":[{"Name":"Admin","Description":"Administrator role.","Id":2},{"Name":"User","Description":"Default system user","Id":3},{"Name":"ScrumMaster","Description":"Scrum master role.","Id":1}],"Id":1}]}]
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHub_onUserLogged
                                                        object:self
                                                      userInfo:@{@"userDto": userDto}];
}

- (void)onState: (NSDictionary *) state
{
    // invoked after onUserLogged and indicate - connection is ok
    //[{"UserId":1,"SessionId":"dbd8ef85-a4f7-4bba-901e-c382db007d7c"}]
    sessionId = [state objectForKey:@"SessionId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHub_onConnected
                                                        object:self
                                                      userInfo:@{@"sessionDto": state}];
}

-(void)onErrorHandler: (NSDictionary *) messageDto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHub_onErrorCatched
                                                        object:self
                                                      userInfo:@{@"messageDto": messageDto}];
}


-(void)onHubStateChanged: (NSDictionary *) roomDto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHub_onRoomChanged
                                                        object:self
                                                      userInfo:@{@"roomDto": roomDto}];
}

-(void)onInitRoom: (NSDictionary *) roomDto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubRoom_onOpened
                                                        object:self
                                                      userInfo:@{@"roomDto": roomDto}];
}

-(void)onRoomStateChanged: (NSDictionary *) roomDto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubRoom_onChanged
                                                        object:self
                                                      userInfo:@{@"roomDto": roomDto}];
}

-(void)onJoinedRoom: (NSDictionary *) userDto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubRoom_onUserJoined
                                                        object:self
                                                      userInfo:@{@"userDto": userDto}];
}

-(void)onLeftRoom: (NSDictionary *) userDto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubRoom_onUserLeft
                                                        object:self
                                                      userInfo:@{@"userDto": userDto}];
}

-(void)onUserVoted: (NSDictionary *) userVoteDto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubRoom_onUserVoted
                                                        object:self
                                                      userInfo:@{@"userVoteDto": userVoteDto}];
}

-(void)onVoteFinished: (NSDictionary *) voteDto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubRoom_onVoteFinished
                                                        object:self
                                                      userInfo:@{@"voteDto": voteDto}];
}

-(void)onVoteItemOpened: (NSDictionary *) voteDto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubRoom_onVoteOpened
                                                        object:self
                                                      userInfo:@{@"voteDto": voteDto}];
}

-(void)onVoteItemClosed: (NSDictionary *) voteDto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHubRoom_onVoteClosed
                                                        object:self
                                                      userInfo:@{@"voteDto": voteDto}];
}
#pragma mark - event notitifocations

- (void) joinRoom: (NSString *) roomName {
    [hub   invoke:@"JoinRoom"
         withArgs:@[roomName, sessionId]];
}

-(void) notify_JoinRoom:(NSNotification*) notification {
    [self joinRoom:notification.userInfo[@"roomName"]];
}

- (void) leaveRoom: (NSString *) roomName {
    [hub   invoke:@"LeaveRoom"
         withArgs:@[roomName, sessionId]];
}

- (void) notify_LeaveRoom: (NSNotification*) notification {
    [self leaveRoom:notification.userInfo[@"roomName"]];
}

- (void) room: (NSString *) roomName withVote: (NSInteger) voteId doVote: (NSInteger) voteValue {
    [hub   invoke:@"VoteForItem"
         withArgs:@[roomName, [NSString stringWithFormat:@"%d", voteId], [NSString stringWithFormat:@"%d", voteValue]]];
}

- (void) notify_Vote: (NSNotification*) notification {
    [self     room:notification.userInfo[@"roomName"]
          withVote:[notification.userInfo[@"voteId"] integerValue]
            doVote:[notification.userInfo[@"voteValue"] integerValue]];
}

@end
