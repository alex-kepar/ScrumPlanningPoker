//
//  RoomsViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SelectRoomViewController.h"
#import "SPPProperties.h"
#import "SRVersion.h"

@interface SelectRoomViewController ()
{
    NSArray *rooms;
    SPPProperties *properties;
}

@end

@implementation SelectRoomViewController

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
    
    properties=[SPPProperties sharedProperties];
    
    self.navigationItem.prompt=properties.server;
    self.navigationItem.title=@"select room";
    
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/WebSignalR/api/room/GetRooms", properties.server]]];
    NSURLSession *session = [NSURLSession sharedSession];
    //NSLog(@"%@", session.configuration.URLCache);
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (error == nil)
            {
                NSArray *roomsList = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                for (NSDictionary *user in roomsList)
                {
                    NSLog(@"Id=%@", [user objectForKey:@"Id"]);
                    NSLog(@"Name=%@", [user objectForKey:@"Name"]);
                    NSLog(@"Description=%@", [user objectForKey:@"Description"]);
                    NSLog(@"Active=%d", [[user objectForKey:@"Active"] boolValue]);
                }
                NSArray *activeRooms = [roomsList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bind)
                    {
                        return [[(NSDictionary *) obj objectForKey:@"Active"] boolValue];
                    }]];
                NSArray *inactiveRooms = [roomsList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bind)
                    {
                        return ![[(NSDictionary *) obj objectForKey:@"Active"] boolValue];
                    }]];
                rooms = [[NSArray alloc] initWithObjects:activeRooms, inactiveRooms, nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tvRooms reloadData];
                });

                SRHubConnection *hubConnection = [SRHubConnection connectionWithURL:[NSString stringWithFormat:@"http://%@/WebSignalR", properties.server]];
                [hubConnection setProtocol:[[SRVersion alloc] initWithMajor:1 minor: 2]];
                [hubConnection addValue:[NSString stringWithFormat:@".ASPXAUTH=%@", properties.userToken] forHTTPHeaderField:@"Cookie"];
                
                properties.agileHub = [SPPAgileHub SPPAgileHubWithHubConnection:hubConnection];
                properties.hubConnection=hubConnection;
                
                [hubConnection setDelegate:self];
                [hubConnection start];
                //[self lockView];
            }
            else
            {
                [self showMessage:[NSString stringWithFormat:@"%@", [error localizedDescription]] withTitle:@"Error connection"];
            }
        }];
    [task resume];
}


-(void)viewDidDisappear:(BOOL)animated
{
    //if (properties.hubConnection != nil) {
    //    [properties.hubConnection disconnect];
    //    properties.hubConnection = nil;
    //}
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RoomCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSDictionary *roomItem = [[rooms objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [roomItem objectForKey:@"Name"];
    cell.detailTextLabel.text = [roomItem objectForKey:@"Description"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[rooms objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0)
    {
        return @"Active rooms:";
    }
    else
    {
        return @"Inactive rooms:";
    }
}
#pragma mark -

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    properties.selectedRoom = [rooms[indexPath.section][indexPath.row] objectForKey:@"Name"];
}
#pragma mark -

#pragma mark SRConnection Delegate
- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    NSLog(@"***** SRConnectionDidOpen invoked");
    [self unLockView];
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{
    NSLog(@"***** SRConnection did receive data invoked Data:\n%@", data);
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
    [self unLockView];
    [self showMessage:[NSString stringWithFormat:@"%@", [error localizedDescription]] withTitle:@"Error connection"];

}

#pragma mark -


@end
