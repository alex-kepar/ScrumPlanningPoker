//
//  RoomsViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SelectRoomViewController.h"
#import "SPPProperties.h"
#import "SPPRoomViewCell.h"
#import "SRVersion.h"

@interface SelectRoomViewController ()
{
    SPPProperties* properties;
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
    
    self.navigationItem.prompt=properties.connection.server;
    self.navigationItem.title=@"select room";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    properties.agileHub.roomDelegate=self;
    [_tvRooms reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (properties.agileHub.roomDelegate == self) {
        properties.agileHub.roomDelegate=Nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 2;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RoomCell";
    SPPRoomViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell==nil)
    {
        cell = [[SPPRoomViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    SPPRoom* room=[properties.roomList objectAtIndex:indexPath.row];
    cell.nameLabel.text = room.name;
    cell.descriptionLabel.text = room.description;
    cell.statusImage.image = [self imageForRoomStatus: room.isActive];
    cell.usersCount.text = [NSString stringWithFormat:@"%d", room.connectedUsers.count];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return properties.roomList.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
    //if (section==0)
    //{
    //    return @"Active rooms:";
    //}
    //else
    //{
    //    return @"Inactive rooms:";
    //}
//}

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

#pragma mark -

#pragma mark + UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    properties.room = properties.roomList[indexPath.row];
}
#pragma mark - UITableViewDelegate

#pragma mark + SPPAgileHubRoomDelegate

- (void)agileHubRoomChanged:(SPPRoom *)room
{
    NSInteger idx = [properties.roomList indexOfObjectPassingTest:^BOOL(SPPRoom* roomItem, NSUInteger idx, BOOL *stop) {
        return (roomItem.roomId == room.roomId);
    }];
    if (idx != NSNotFound) {
        [properties.roomList replaceObjectAtIndex:idx withObject:room];
    }
    else {
        [properties.roomList addObject:room];
    }
    //dispatch_async(dispatch_get_main_queue(), ^{
    [_tvRooms reloadData];
    //});
}

#pragma mark - SPPAgileHubRoomDelegate*/



@end
