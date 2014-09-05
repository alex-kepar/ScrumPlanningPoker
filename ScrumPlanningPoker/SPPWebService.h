//
//  SPPConnection.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/23/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPPWebService;

@protocol SPPWebServiceDelegate<NSObject, NSURLSessionTaskDelegate>
//@required
@optional
- (void)webService:(SPPWebService*)service didConnected:(NSString*)server;
- (void)webService:(SPPWebService*)service didReceiveError:(NSError*)error;
- (void)webService:(SPPWebService*)service didReceiveRoomList:(NSArray*)data;
@end

@interface SPPWebService : NSObject

@property (readonly) NSString* server;
@property (readonly) NSString* login;
@property (readonly) NSString* userToken;
@property (nonatomic, weak)id <SPPWebServiceDelegate> delegate;

-(void)connectTo: (NSString*) server Login: (NSString*) login Password: (NSString*) password;
-(void)getRoomList;
@end
