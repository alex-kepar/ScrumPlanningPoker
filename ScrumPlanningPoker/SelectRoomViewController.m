//
//  RoomsViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SelectRoomViewController.h"
#import "SPPRoomViewCell.h"
//#import "SRVersion.h"
#import "RoomViewController.h"
//#import "SPPAgileHubNotifications.h"
//#import "SPPAgileHub.h"

@interface SelectRoomViewController ()
{
    //NSDictionary *selectedRoomDto;
    //SPPAgileHub *agileHub;
}
@end

@implementation SelectRoomViewController

@synthesize promptRoot;
//@synthesize roomListDto;
@synthesize agileHubFacade;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.prompt=promptRoot;
    self.navigationItem.title=@"select room";
    //agileHubFacade.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyAgileHubFacade_onChanged:)
                                                 name:SPPAgileHubFacade_onChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyAgileHubFacade_onDidOpenRoom:)
                                                 name:SPPAgileHubFacade_onDidOpenRoom
                                               object:nil];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [agileHubFacade closeRoom];
    //if (selectedRoomDto != nil) {
    //    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHub_LeaveRoom
    //                                                        object:self
    //                                                      userInfo:@{@"roomName": [selectedRoomDto valueForKey:@"Name"]}];
    //    selectedRoomDto = nil;
    //}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark + UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return agileHubFacade.rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPPRoomViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RoomCell" forIndexPath:indexPath];
    if(cell!=nil)
    {
        [cell initializeWithRoom:agileHubFacade.rooms[indexPath.row]];
    }
    return cell;
}

#pragma mark - UITableViewDataSource

#pragma mark + UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self lockView];
    [agileHubFacade openRoomUseIndex:indexPath.row];
}
#pragma mark - UITableViewDelegate

#pragma mark + segue handling
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RoomSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[RoomViewController class]]) {
            RoomViewController *roomViewController = (RoomViewController *)segue.destinationViewController;
            roomViewController.room = agileHubFacade.openedRoom;
            roomViewController.promptRoot = self.navigationItem.prompt;
        }
    }
}
#pragma mark - segue handling

-(void) notifyAgileHubFacade_onChanged:(NSNotification*) notification {
    if (notification.object == agileHubFacade && notification.userInfo) {
        if ([notification.userInfo valueForKey:@"list"] == agileHubFacade.rooms) {
            [self.tvRooms reloadData];
        }
    }
}

-(void) notifyAgileHubFacade_onDidOpenRoom:(NSNotification*) notification {
    [self unlockView];
    [self performSegueWithIdentifier:@"RoomSegue" sender:self];
}

@end
