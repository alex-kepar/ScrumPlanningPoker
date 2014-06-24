//
//  SPPConnection.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/23/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPPConnection;

@protocol SPPConnectionDelegate<NSObject>
//@required
@optional
- (void)connectionDidOpen: (SPPConnection *) connection;
- (void)connection:(SPPConnection *) connection didReceiveError: (NSError *) error;
- (void)connection:(SPPConnection *) connection didReceiveRoomList: (NSArray *) data;
@end

@interface SPPConnection : NSObject

@property (strong, nonatomic, readonly) NSString* server;
@property (strong, nonatomic, readonly) NSString* login;
@property (strong, nonatomic, readonly) NSString* userToken;
@property (nonatomic, assign)id <SPPConnectionDelegate> connectionDelegate;

-(void)ConnectTo: (NSString*) server Login: (NSString*) login Password: (NSString*) password;
-(void)GetRoomList;
@end
