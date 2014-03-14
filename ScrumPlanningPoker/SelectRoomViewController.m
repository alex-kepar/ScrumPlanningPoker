//
//  RoomsViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SelectRoomViewController.h"
#import "SPPProperties.h"

@interface SelectRoomViewController ()
{
    NSArray *rooms;
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
    
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/WebSignalR/api/room/GetRooms",  [SPPProperties sharedProperties].server ]]];
    NSURLSession *session = [NSURLSession sharedSession];
    //NSLog(@"%@", session.configuration.URLCache);
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (error == nil)
            {
                NSArray *roomsList = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                for (NSDictionary *user in rooms)
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
            }
            else
            {
                [self showMessage:[NSString stringWithFormat:@"%@", [error localizedDescription]] withTitle:@"Error connection"];
            }
        }];
    [task resume];
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
    //if (indexPath.section == 0)
    //{
    //    roomItem = activeRooms[indexPath.row];
    //}
    //else
    //{
    //    roomItem = inactiveRooms[indexPath.row];
    //}
    
    //NSLog(@"Id=%@", [user objectForKey:@"Id"]);
    //NSLog(@"Name=%@", [user objectForKey:@"Name"]);
    //NSLog(@"Description=%@", [user objectForKey:@"Description"]);
    //NSLog(@"Active=%d", [[user objectForKey:@"Active"] boolValue]);
    
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
    [SPPProperties sharedProperties].room = [rooms[indexPath.section][indexPath.row] objectForKey:@"Name"];
}
#pragma mark -

@end
