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
#import "SPPRoom.h"
#import "RoomViewController.h"

@interface SelectRoomViewController ()
{
    //SPPProperties *properties;
    SPPRoom *selectedRoom;
    NSMutableArray *roomList;
}

@end

@implementation SelectRoomViewController

@synthesize agileHub;
@synthesize promptRoot;
//@synthesize roomList;
@synthesize roomListData;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //properties=[SPPProperties sharedProperties];
    self.navigationItem.prompt=promptRoot;
    self.navigationItem.title=@"select room";

    roomList = [[NSMutableArray alloc] initWithCapacity:roomListData.count];
    for (int i = 0; i < roomListData.count; i++) {
        roomList[i] = [self _createRoomUseData:roomListData[i]];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    agileHub.stateDelegate = self;
    agileHub.roomDelegate = nil;
    //agileHub.voteDelegate = nil;
    if (selectedRoom != nil) {
        selectedRoom.delegate = nil;
        //selectedRoom.roomDelegate = nil;
        [agileHub leaveRoom:selectedRoom.name];
        selectedRoom = nil;
    }
}

//-(void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    if (properties.agileHub.delegate == self) {
//        properties.agileHub.delegate=nil;
//    }
//    if (properties.connection.connectionDelegate == self) {
//        properties.connection.connectionDelegate=nil;
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark + UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RoomCell";
    SPPRoomViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell==nil)
    {
        cell = [[SPPRoomViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    SPPRoom* room=[roomList objectAtIndex:indexPath.row];
    cell.nameLabel.text = room.name;
    cell.descriptionLabel.text = room.description;
    cell.statusImage.image = [self imageForRoomStatus: room.isActive];
    cell.usersCount.text = [NSString stringWithFormat:@"%d", room.connectedUsers.count];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return roomList.count;
}

-(UIImage *) imageForRoomStatus: (BOOL)isOpened
{
    if(isOpened)
    {
        return [UIImage imageNamed:@"RoomOpened.png"];
    }
    else
    {
        return [UIImage imageNamed:@"RoomClosed.png"];
    }
}

#pragma mark - UITableViewDataSource

#pragma mark + UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRoom = roomList[indexPath.row];
    [self lockView];
    [agileHub joinRoom:selectedRoom.name];
}
#pragma mark - UITableViewDelegate

#pragma mark + SPPAgileHubStateDelegate

- (SPPRoom*) _createRoomUseData:(NSDictionary*) roomData {
    SPPRoom *room = [SPPRoom SPPBaseEntityWithDataDictionary:roomData];
    room.roomDelegate = self;
    return room;
}

- (SPPRoom*) _GetRoomUseData:(NSDictionary *) roomData {
    NSInteger entityId = [[roomData objectForKey:@"Id"] integerValue];
    NSInteger idx = [roomList indexOfObjectPassingTest:^BOOL(SPPRoom* roomItem, NSUInteger idx, BOOL *stop) {
        return (roomItem.entityId == entityId);
    }];
    SPPRoom *room;
    if (idx != NSNotFound) {
        room = roomList[idx];
        [room updateFromDictionary:roomData];
    }
    else {
        room = [self _createRoomUseData:roomData];
        [roomList addObject:room];
    }
    return room;
}

- (void)agileHubDidChangeState:(NSDictionary *) roomData
{
    [self _GetRoomUseData:roomData];
    [_tvRooms reloadData];
}

- (void)agileHubDidOpenRoom: (NSDictionary *) roomData
{
    [self unLockView];
    selectedRoom = [self _GetRoomUseData:roomData];
    agileHub.roomDelegate = selectedRoom;
    [self performSegueWithIdentifier:@"RoomSegue" sender:self];
}

#pragma mark - SPPAgileHubStateDelegate

#pragma mark + segue handling
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RoomSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[RoomViewController class]]) {
            RoomViewController *roomViewController = (RoomViewController *)segue.destinationViewController;
            roomViewController.room = selectedRoom;
            roomViewController.promptRoot = self.navigationItem.prompt;
        }
    }
}
#pragma mark - segue handling

#pragma mark + SPPRoomDelegate
- (void) SPPRoom:(SPPRoom *) room withVote: (SPPVote*) vote doVote: (NSInteger) voteValue {
    [agileHub room:room.name withVote:vote.entityId doVote:voteValue];
}
#pragma mark - SPPRoomDelegate



@end
