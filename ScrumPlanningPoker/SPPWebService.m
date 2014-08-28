//
//  SPPConnection.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/23/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPWebService.h"

@implementation SPPWebService

@synthesize server;
@synthesize login;
@synthesize userToken;

@synthesize delegate;

- (void)dealloc {
    NSLog(@"********** SPPWebService deallocated.");
}

-(void)connectTo: (NSString*) aServer Login: (NSString*) aLogin Password: (NSString*) aPassword;
{
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/Handlers/LoginHandler.ashx", aServer]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    NSData* passwordData=[aPassword dataUsingEncoding:NSUTF8StringEncoding];
    NSString* passwordEncode=[[passwordData base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData* messageData=[[NSString stringWithFormat:@"%@:%@", aLogin, passwordEncode] dataUsingEncoding:NSUTF8StringEncoding];
    
    [request addValue:[NSString stringWithFormat:@"Basic %@", [messageData base64EncodedStringWithOptions:0]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    __weak SPPWebService *weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
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
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [weakSelf onWebServiceDidOpenWithSerever:aServer
                                                                                              Login:aLogin
                                                                                          UserToken:[(NSHTTPCookie *)cookies[cookieIndex] value]];
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
    [task resume];
}

-(void)reset {
    NSURLSession *session = [NSURLSession sharedSession];
    __weak SPPWebService *weakSelf = self;
    [session resetWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf onWebServiceDidReset];
        });
    }];
}


-(void)getRoomList
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/room/GetRooms", server]];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak SPPWebService *weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      if (error == nil)
                                      {
                                          NSArray* roomsList = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
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
    [task resume];
}

-(void) onWebServiceDidOpenWithSerever:(NSString*)aServer Login:(NSString*)aLogin UserToken:(NSString*)aUserToken
{
    server = aServer;
    login = aLogin;
    userToken = aUserToken;
    if (delegate && [delegate respondsToSelector:@selector(webService:didConnected: )]) {
        [delegate webService:self didConnected:server];
    }
}

-(void) onWebServiceReceiveRoomList: (NSArray *) roomList
{
    if (delegate && [delegate respondsToSelector:@selector(webService:didReceiveRoomList:)]) {
        [delegate webService:self didReceiveRoomList:roomList];
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
        [delegate webService:self didReceiveError:error];
    }
}

-(void) onWebServiceDidReset {
    if (delegate && [delegate respondsToSelector:@selector(webService:didReset:)]) {
        [delegate webService:self didReset:server];
    }
}
@end
