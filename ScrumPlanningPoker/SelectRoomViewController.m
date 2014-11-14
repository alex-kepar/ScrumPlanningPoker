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

@end

@implementation SelectRoomViewController

@synthesize promptRoot;
@synthesize agileHubFacade;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.prompt=promptRoot;
    self.navigationItem.title=@"Rooms";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyAgileHubFacade_onChanged:)
                                                 name:SPPAgileHubFacade_onChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyAgileHubFacade_onDidOpenRoom:)
                                                 name:SPPAgileHubFacade_onDidOpenRoom
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [agileHubFacade closeRoom];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

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
        //cell.changeStateAction = ^(SPPRoom *room){
        //    [room changeState:!room.isActive];
        //};
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self lockView];
    [agileHubFacade openRoomUseIndex:indexPath.row];
}

#pragma mark - segue handling
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RoomSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[RoomViewController class]]) {
            RoomViewController *roomViewController = (RoomViewController *)segue.destinationViewController;
            roomViewController.room = agileHubFacade.openedRoom;
            roomViewController.currentUser = agileHubFacade.currentUser;
            roomViewController.promptRoot = self.navigationItem.prompt;
        }
    }
}
#pragma mark -

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
