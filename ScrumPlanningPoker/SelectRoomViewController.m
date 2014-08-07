//
//  RoomsViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SelectRoomViewController.h"
#import "SPPRoomViewCell.h"
#import "SRVersion.h"
#import "RoomViewController.h"
#import "SPPAgileHubNotifications.h"

@interface SelectRoomViewController ()
{
    NSDictionary *selectedRoomDto;
}

@end

@implementation SelectRoomViewController

@synthesize promptRoot;
@synthesize roomListDto;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.prompt=promptRoot;
    self.navigationItem.title=@"select room";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyAgileHubRoom_Opened:) name:SPPAgileHubRoom_onOpened object:nil];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (selectedRoomDto != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHub_LeaveRoom
                                                            object:self
                                                          userInfo:@{@"roomName": [selectedRoomDto valueForKey:@"Name"]}];
        selectedRoomDto = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark + UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return roomListDto.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPPRoomViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RoomCell" forIndexPath:indexPath];
    if(cell!=nil)
    {
        [cell initializeWithRoomDto:roomListDto[indexPath.row]];
    }
    return cell;
}

#pragma mark - UITableViewDataSource

#pragma mark + UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRoomDto = roomListDto[indexPath.row];
    [self lockView];
    NSString *name = [selectedRoomDto valueForKey:@"Name"];
    if (name !=nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHub_JoinRoom
                                                            object:self
                                                          userInfo:@{@"roomName": name}];
    }
}
#pragma mark - UITableViewDelegate

-(void) notifyAgileHubRoom_Opened:(NSNotification*) notification {
    [self unLockView];
    selectedRoomDto = notification.userInfo[@"roomDto"];
    [self performSegueWithIdentifier:@"RoomSegue" sender:self];
}

#pragma mark + segue handling
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RoomSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[RoomViewController class]]) {
            RoomViewController *roomViewController = (RoomViewController *)segue.destinationViewController;
            roomViewController.roomDto = selectedRoomDto;
            roomViewController.promptRoot = self.navigationItem.prompt;
        }
    }
}
#pragma mark - segue handling

@end
