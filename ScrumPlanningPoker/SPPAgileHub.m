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
@synthesize connectionDelegate;

- (void)dealloc {
    NSLog(@"********** SPPAgileHub deallocated.");
}

- (void) Disconnect
{
    if (hubConnection) {
        [hubConnection stop];
        //[hubConnection didClose];
        hubConnection = nil;
    }
}

- (void) ConnectTo:(NSString *) server
{
    [self Disconnect];
    hubConnection = [SRHubConnection connectionWithURL:[NSString stringWithFormat:@"http://%@", server]];
    [hubConnection setProtocol:[[SRVersion alloc] initWithMajor:1 minor: 2]];
    //[hubConnection setReceived:(onReceived)received]
    //hubConnection.received = ^(NSString * dataReceived){
    //    NSLog(@"***********************************\n***********************************\nData received:\n%@", dataReceived);
    //};
    //hubConnection.closed = ^() {
    //    NSLog(@"********** hubConnection closed.");
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

#pragma mark - SRConnection Delegate retranslate to SPPAgileHubConnectDelegate
- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHub:ConnectionDidOpen:)])
    {
        __weak SPPAgileHub *weakSelf = self;
        [connectionDelegate agileHub:weakSelf ConnectionDidOpen:connection];
    }
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{
    //NSLog(@"***** SRHubConnection did receive data invoked Data:\n%@", data);
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHub:ConnectionDidClose:)])
    {
        __weak SPPAgileHub *weakSelf = self;
        [connectionDelegate agileHub:weakSelf ConnectionDidClose:connection];
    }
}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(agileHub:Connection:didReceiveError:)])
    {
        __weak SPPAgileHub *weakSelf = self;
        [connectionDelegate agileHub:weakSelf Connection:connection didReceiveError:error];
    }
}

#pragma mark - event notitifocations
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
#pragma mark -

- (void) joinRoom: (NSString *) roomName {
    [hub   invoke:@"JoinRoom"
         withArgs:@[roomName, sessionId]];
}

//-(void) notify_JoinRoom:(NSNotification*) notification {
//    [self joinRoom:notification.userInfo[@"roomName"]];
//}
//
- (void) leaveRoom: (NSString *) roomName {
    [hub   invoke:@"LeaveRoom"
         withArgs:@[roomName, sessionId]];
}

//- (void) notify_LeaveRoom: (NSNotification*) notification {
//    [self leaveRoom:notification.userInfo[@"roomName"]];
//}

- (void) room:(NSString*)roomName withVote:(NSInteger)voteId doVote:(NSInteger)voteValue {
    [hub   invoke:@"VoteForItem"
         withArgs:@[roomName, [@(voteId) stringValue], [@(voteValue) stringValue]]];
}

- (void)room:(NSString*)roomName openVote:(NSInteger)voteId {
    [hub invoke:@"OpenVoteItem"
       withArgs:@[roomName, [NSString stringWithFormat:@"%ld", (long)voteId]]];
}

- (void)room:(NSString*)roomName closeVote:(NSInteger)voteId withOveralValue:(NSInteger)overalValue {
    [hub invoke:@"CloseVoteItem"
       withArgs:@[roomName, [NSString stringWithFormat:@"%ld", (long)voteId], [NSString stringWithFormat:@"%ld", (long)overalValue]]];
}

- (void)room:(NSString*)roomName changeState:(BOOL)newState {
    [hub invoke:@"ChangeRoomState"
       withArgs:@[roomName, [NSString stringWithFormat:@"%@", newState?@"true":@"false"]]];
}

- (void)room:(NSString*)roomName removeVote:(NSInteger)voteId {
    [hub invoke:@"RemoveVote"
       withArgs:@[roomName, [@(voteId) stringValue]]];
}

@end
