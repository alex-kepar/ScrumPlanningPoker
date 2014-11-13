//
//  SPPConnection.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/23/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPWebService.h"
#import <AFNetworking/AFNetworking.h>

@interface SPPWebService ()

@property (strong, nonatomic)  NSURLSession *session;

@end

@implementation SPPWebService {
    NSURLSessionDataTask *connectDataTask;
    NSURLSessionDataTask *roomListDataTask;
    NSURLSessionDataTask *roomHandlingDataTask;
}

@synthesize server;
@synthesize login;
@synthesize userToken;

@synthesize delegate;

- (void)dealloc {
    if (self.session) {
        [self.session invalidateAndCancel];
    }
    NSLog(@"********** SPPWebService deallocated.");
}

-(NSURLSession*)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _session;
}

-(void)connectTo: (NSString*) aServer Login: (NSString*) aLogin Password: (NSString*) aPassword;
{
    if (connectDataTask) {
        [connectDataTask cancel];
    }

    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/Handlers/LoginHandler.ashx", aServer]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url]; //] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    NSData* passwordData=[aPassword dataUsingEncoding:NSUTF8StringEncoding];
    NSString* passwordEncode=[[passwordData base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData* messageData=[[NSString stringWithFormat:@"%@:%@", aLogin, passwordEncode] dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:[NSString stringWithFormat:@"Basic %@", [messageData base64EncodedStringWithOptions:0]] forHTTPHeaderField:@"Authorization"];
    
    __weak SPPWebService *weakSelf = self;
    connectDataTask = [self.session dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                       {
                           if (error == nil)
                           {
                               NSInteger status = [(NSHTTPURLResponse *)response statusCode];
                               if(status == 200)
                               {
                                   NSArray* cookies = [NSURLSession sharedSession].configuration.HTTPCookieStorage.cookies;
                                   NSUInteger cookieIndex=[cookies indexOfObjectPassingTest:^BOOL(id cookieId, NSUInteger idx, BOOL *stop)
                                                           {
                                                               if([[(NSHTTPCookie *)cookieId name] isEqualToString:@".ASPXAUTH"])
                                                               {
                                                                   *stop=YES;
                                                                   return YES;
                                                               }
                                                               return NO;
                                                           }];
                                   if (cookieIndex != NSNotFound)
                                   {
                                       NSString *aUserToken = [(NSHTTPCookie *)cookies[cookieIndex] value];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [weakSelf onWebServiceDidOpenWithSerever:aServer
                                                                              Login:aLogin
                                                                          UserToken:aUserToken];
                                       });
                                   }
                                   else
                                   {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [weakSelf onWebServiceDidReceiveErrorMessage:@"Authorization not passed"];
                                       });
                                   }
                               }
                               else
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [weakSelf onWebServiceDidReceiveErrorMessage:[NSString stringWithFormat:@"%@", [NSHTTPURLResponse localizedStringForStatusCode: status ]]];
                                   });
                               }
                           }
                           else
                           {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [weakSelf onWebServiceDidReceiveError:error];
                               });
                           }
                       }];
    if (connectDataTask) {
        [connectDataTask resume];
    }
}

-(void)getRoomList
{
    if (roomListDataTask) {
        [roomListDataTask cancel];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/room/GetRooms", server]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    __weak SPPWebService *weakSelf = self;
    roomListDataTask = [self.session dataTaskWithRequest:request
                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                        {
                            if (error == nil)
                            {
                                NSArray* roomsList = [NSJSONSerialization JSONObjectWithData:data
                                                                                     options:0
                                                                                       error:&error];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf onWebServiceReceiveRoomList:roomsList];
                                });
                            }
                            else
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf onWebServiceDidReceiveError:error];
                                });
                            }
                        }];
    if (roomListDataTask) {
        [roomListDataTask resume];
    }
}

-(void)removeUser:(NSInteger)userId fromRoom:(NSInteger)roomId {
    if (roomHandlingDataTask) {
        [roomHandlingDataTask cancel];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/room/LeaveRoom?roomId=%ld&userId=%ld", server, roomId, userId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PUT"];
    
    __weak SPPWebService *weakSelf = self;
    roomHandlingDataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf onWebServiceDidReceiveError:error];
            });
        }
    }];
    if (roomHandlingDataTask) {
        [roomHandlingDataTask resume];
    }
}

-(void) onWebServiceDidOpenWithSerever:(NSString*)aServer Login:(NSString*)aLogin UserToken:(NSString*)aUserToken
{
    server = aServer;
    login = aLogin;
    userToken = aUserToken;
    if (delegate && [delegate respondsToSelector:@selector(webService:didConnected: )]) {
        __weak SPPWebService *weakSelf = self;
        [delegate webService:weakSelf didConnected:server];
    }
}

-(void) onWebServiceReceiveRoomList: (NSArray *) roomList
{
    if (delegate && [delegate respondsToSelector:@selector(webService:didReceiveRoomList:)]) {
        __weak SPPWebService *weakSelf = self;
        [delegate webService:weakSelf didReceiveRoomList:roomList];
    }
}

-(void) onWebServiceDidReceiveErrorMessage: (NSString*) message
{
    NSDictionary *errorDetail = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    NSError *error=[NSError errorWithDomain:@"SPPWebService" code:-100 userInfo:errorDetail];
    [self onWebServiceDidReceiveError:error];
}
    
-(void) onWebServiceDidReceiveError: (NSError *) error
{
    if (delegate && [delegate respondsToSelector:@selector(webService:didReceiveError:)]) {
        __weak SPPWebService *weakSelf = self;
        [delegate webService:weakSelf didReceiveError:error];
    }
}
@end
