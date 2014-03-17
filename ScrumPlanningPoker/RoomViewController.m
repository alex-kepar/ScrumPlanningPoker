//
//  RoomViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "RoomViewController.h"
#import "SPPProperties.h"
#import "SignalR.h"
#import "SRVersion.h"

@interface RoomViewController ()
{
    SRHubConnection *roomConnection;
    SRHubProxy *roomHub;
}
@end

@implementation RoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    SPPProperties *properties=[SPPProperties sharedProperties];
    self.navigationItem.prompt=[NSString stringWithFormat:@"%@ / %@", properties.server, properties.room];

    //roomConnection = [SRHubConnection connectionWithURL:[NSString stringWithFormat:@"http://%@/SignalRMvc", properties.server]];
    roomConnection = [SRHubConnection connectionWithURL:[NSString stringWithFormat:@"http://%@/WebSignalR", properties.server]];
    
    SRVersion *pr=[[SRVersion alloc] initWithMajor:1 minor: 2];
    //[roomConnection verifyProtocolVersion: @""];
    [roomConnection setProtocol:pr];
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
        NSHTTPCookie *cookie = cookies[cookieIndex];
        //[roomConnection addValue:[NSString stringWithFormat:@".ASPXAUTH=%@", [cookie.value stringByReplacingOccurrencesOfString:@"\n" withString:@""]] forHTTPHeaderField:@"Cookie"];
        [roomConnection addValue:[NSString stringWithFormat:@".ASPXAUTH=%@", [cookie.value stringByReplacingOccurrencesOfString:@"\n" withString:@""]] forHTTPHeaderField:@"Cookie"];
        roomHub = [roomConnection createHubProxy:@"agileHub"];
        //roomHub = [roomConnection createHubProxy:@"chatHub"];
        [roomConnection setDelegate:self];
        [roomConnection start];
        [self lockView];
    }
    else
    {
        [self showMessage:@"Authorization not passed" withTitle:@"Error connect to hub"];
    }
    //NSString *auth=session.configuration.HTTPCookieStorage
    
    //[roomConnection addValue:[NSString stringWithFormat:@".ASPXAUTH=%@", cookie.value] forHTTPHeaderField:@"Cookie" ];
    //            // Connect to the service
    //            connection = [SRHubConnection connectionWithURL: @"http://vinw2617/WebSignalR"];
    //            [connection addValue:[NSString stringWithFormat:@".ASPXAUTH=%@", cookie.value] forHTTPHeaderField:@"Cookie" ];
    //            // Create a proxy to the chat service
    //            hub = [connection createHubProxy:@"agileHub"];
    //            //[hub on:@"addMessage" perform:self selector:@selector(addMessage:message:)];
    //            [connection setDelegate:self];
    //            // Start the connection
    //            [connection start];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SRConnection Delegate
- (void)SRConnectionDidOpen:(SRConnection *)connection
{
     NSLog(@"***** SRConnectionDidOpen invoked");
     [self unLockView];
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{
    NSLog(@"***** SRConnection did receive data invoked");
    //[messagesReceived insertObject:[MessageItem messageItemWithUserName:@"Connection did recieve data" Message:@""] atIndex:0];
    //[tvMessages reloadData];
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
    NSLog(@"***** SRConnectionDidClose invoked");
}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{
    NSLog(@"***** SRConnection did receive error invoked");
}

#pragma mark -

@end
