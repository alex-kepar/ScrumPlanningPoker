//
//  SPPAgileHub.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPAgileHub.h"
#import "SPPProperties.h"

@implementation SPPAgileHub

@synthesize roomDelegate;

@synthesize hubConnection;
@synthesize hub;
@synthesize sessionId;



+ (instancetype) SPPAgileHubWithHubConnection: (SRHubConnection*) initHubConnection
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
        [hub on:@"onUserLogged" perform:self selector:@selector(onHubUserLogged:)];
        [hub on:@"onState" perform:self selector:@selector(onHubState:)];
        [hub on:@"onInitRoom" perform:self selector:@selector(onHubInitRoom:)];
    }
    return self;
}

- (void)onHubUserLogged: (NSDictionary *) userDto
{
    [SPPProperties sharedProperties].user = [SPPUser SPPUserWithDataDictionary:userDto];
    NSLog(@"***** onHubUserLogged Data:\n%@", userDto);
}

- (void)onHubState: (NSDictionary *) state
{
    sessionId = [state objectForKey:@"SessionId"];
    NSLog(@"***** onHubState Data:\n%@", state);
}

-(void)onHubInitRoom: (NSDictionary *) roomDto
{
    NSLog(@"***** onHubInitRoom Data:\n%@", roomDto);
    SPPRoom* room=[SPPRoom SPPRoomWithDataDictionary:roomDto];
    [SPPProperties sharedProperties].room = room;
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(onJoinRoom:)])
    {
        [roomDelegate onJoinRoom:room];
    }
}


- (void) JoinRoom: (NSString *) roomName
{
    if (sessionId == nil)
    {
        return;
    }
    SPPAgileHub * __weak weakSelf = self;
    [hub            invoke:@"joinRoom"
                  withArgs:@[roomName, sessionId]
         completionHandler:^(id response) {
             NSDictionary *resDto=response;
             struct SPPRoomResult res;
             {
                 res.isActive = [[resDto objectForKey:@"Active"] boolValue];
                 res.isHostMaster = [[resDto objectForKey:@"HostMaster"] boolValue];
             }
             NSLog(@"%@", response);
             
             if (weakSelf.roomDelegate && [weakSelf.roomDelegate respondsToSelector:@selector(onDidJoinRoom:)])
             {
                 [weakSelf.roomDelegate onDidJoinRoom:res];
             }
             
         }];
}
     
     
@end
