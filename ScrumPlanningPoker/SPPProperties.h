//
//  SPPHTPPHandling.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalR.h"
#import "SPPUser.h"
#import "SPPAgileHub.h"
#import "SPPConnection.h"

@interface SPPProperties : NSObject

//@property NSString* server;
//@property NSString* selectedRoom;
//@property NSString* userToken;
@property SPPUser* user;
@property SPPRoom *room;
@property NSMutableArray *roomList;
//@property SRHubConnection* hubConnection;
@property (readonly) SPPConnection* connection;
@property SPPAgileHub* agileHub;


+ (SPPProperties *)sharedProperties;

@end
