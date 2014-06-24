//
//  SPPConnection.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/23/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPConnection.h"

@implementation SPPConnection

@synthesize server;
@synthesize login;
@synthesize userToken;

@synthesize connectionDelegate;

-(void)ConnectTo: (NSString*) aServer Login: (NSString*) aLogin Password: (NSString*) aPassword;
{
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/Handlers/LoginHandler.ashx", aServer]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    NSData* passwordData=[aPassword dataUsingEncoding:NSUTF8StringEncoding];
    NSString* passwordEncode=[[passwordData base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData* messageData=[[NSString stringWithFormat:@"%@:%@", aLogin, passwordEncode] dataUsingEncoding:NSUTF8StringEncoding];
    
    [request addValue:[NSString stringWithFormat:@"Basic %@", [messageData base64EncodedStringWithOptions:0]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      //[self unLockView];
                                      if (error == nil)
                                      {
                                          NSInteger status = [(NSHTTPURLResponse *)response statusCode];
                                          if(status == 200)
                                          {
                                              //properties = [SPPProperties sharedProperties];
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
                                                  server = aServer;
                                                  login = aLogin;
                                                  userToken = [(NSHTTPCookie *)cookies[cookieIndex] value];
                                                  //properties.userToken = [(NSHTTPCookie *)cookies[cookieIndex] value];
                                                  //properties.server = _txtServer.text;
                                                  //properties.hubConnection = nil;
                                                  //dispatch_async(dispatch_get_main_queue(), ^{
                                                  //    [self performSegueWithIdentifier:@"ShowRooms" sender:self];
                                                  //});
                                                  //dispatch_async(dispatch_get_main_queue(), ^{
                                                  //    [self performSegueWithIdentifier:@"TestSegue" sender:self];
                                                  //});
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self EventConnectionDidOpen];
                                                      });
                                              }
                                              else
                                              {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self EventConnectionDidReceiveErrorMessage:@"Authorization not passed"];
                                                  });
                                              }
                                          }
                                          else
                                          {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [self EventConnectionDidReceiveErrorMessage:[NSString stringWithFormat:@"%@", [NSHTTPURLResponse localizedStringForStatusCode: status ]]];
                                              });
                                          }
                                      }
                                      else
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self EventConnectionDidReceiveError:error];
                                          });
                                      }
                                  }];
    [task resume];
}

-(void)GetRoomList
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/room/GetRooms", server]];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      if (error == nil)
                                      {
                                          NSArray* roomsList = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self EventConnectionReceiveRoomList:roomsList];
                                          });
                                      }
                                      else
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self EventConnectionDidReceiveError:error];
                                          });
                                      }
                                  }];
    [task resume];
}

-(void) EventConnectionDidOpen
{
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connectionDidOpen:)])
    {
        [connectionDelegate connectionDidOpen:self];
    }
}

-(void) EventConnectionReceiveRoomList: (NSArray *) roomList
{
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:didReceiveRoomList:)])
    {
        [connectionDelegate connection:self didReceiveRoomList:roomList];
    }
}

-(void) EventConnectionDidReceiveErrorMessage: (NSString*) message
{
    NSDictionary *errorDetail = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    NSError *error=[NSError errorWithDomain:@"SPPConnection" code:-100 userInfo:errorDetail];
    [self EventConnectionDidReceiveError:error];
}
    
-(void) EventConnectionDidReceiveError: (NSError *) error
{
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:didReceiveError:)])
    {
        [connectionDelegate connection:self didReceiveError:error];
    }
}

@end
