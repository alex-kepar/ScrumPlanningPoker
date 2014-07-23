//
//  RoomViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "RoomViewController.h"
#import "SPPProperties.h"
//#import "SignalR.h"
#import "SPPUser.h"
#import "SPPVote.h"
#import "SPPUserViewCell.h"
#import "SPPVoteViewCell.h"
#import "VoteViewController.h"

@interface RoomViewController ()
{
    //SPPProperties *properties;
    //SPPAgileHub *hub;
    //SPPRoom *room;
    SPPVote *selectedVote;
}
@end

@implementation RoomViewController

@synthesize room;
@synthesize promptRoot;
@synthesize agileHub;

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
    //properties = [SPPProperties sharedProperties];
    //hub = properties.agileHub;
    self.navigationItem.prompt = [NSString stringWithFormat:@"%@/%@", promptRoot, room.name];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    agileHub.roomDelegate = self;
    agileHub.voteDelegate = self;
    room.delegate = self;
    room.roomDelegate = self;
    //[hub joinRoom:properties.room.name];
    //[self lockView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[agileHub leaveRoom:room.name];
    //if (room.delegate == self) {
    //    room.delegate = nil;
    //}
    //if (hub.delegate == self) {
    //    hub.delegate = nil;
    //}
}

#pragma mark + SPPAgileHubRoomDelegate

- (void)agileHubDidJoinUser: (NSDictionary *) userData {
    [room addUserUseData:userData];
    //NSLog(@"Joined user %@", user.name);
    //[_cvUsers reloadData];
}

- (void)agileHubDidLeaveUser: (NSDictionary *) userData {
    [room removeUserUseData:userData];
    //NSLog(@"Left user %@", user.name);
    //[_cvUsers reloadData];
}

- (void)agileHubDidChangeRoom: (NSDictionary *) roomData {
    [room updateFromDictionary:roomData];
}

#pragma makr - SPPAgileHubRoomDelegate

#pragma mark + UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return room.connectedUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPPUserViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
    
    if (cell != nil)
    {
        cell.user = room.connectedUsers[indexPath.row];
        cell.selectedVote = selectedVote;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
#pragma mark - UICollectionViewDataSource


#pragma mark + UITableViewDataSource

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    //return 2;
//    return 1;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPPVoteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoteCell" forIndexPath:indexPath];
    if (cell != nil) {
        cell.vote = [room.itemsToVote objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return room.itemsToVote.count;
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

#pragma mark - UITableViewDataSource

#pragma mark + UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedVote = [self.room.itemsToVote objectAtIndex:indexPath.row];
    for (int i=0; i<room.connectedUsers.count; i++) {
        SPPUserViewCell *cell = (SPPUserViewCell*)[_cvUsers cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (!cell) continue;
        cell.selectedVote = selectedVote;
    }
}
#pragma mark - UITableViewDelegate

#pragma mark + segue handling
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"VoteSeque"]) {
        NSIndexPath *indexPath;
        if ([sender isKindOfClass:[UIButton class]]) {
            //UITableViewCell *clickedCell = (UITableViewCell*)[sender superview];
            UITableViewCell *clickedCell = (UITableViewCell*)[[[sender superview] superview] superview];
            indexPath = [self.tvVotes indexPathForCell:clickedCell];
            //indexPath = [self.tvVotes indexOfAccessibilityElement:sender];
        } else {
            indexPath = [self.tvVotes indexPathForSelectedRow];
        }
        if ([segue.destinationViewController isKindOfClass:[VoteViewController class]] && indexPath !=nil) {
            //NSIndexPath *indexPath = [self.tvVotes indexPathForSelectedRow];
            VoteViewController *voteController = (VoteViewController *)segue.destinationViewController;
            voteController.room = self.room;
            voteController.vote = [self.room.itemsToVote objectAtIndex:indexPath.row];
            voteController.promptRoot = self.navigationItem.prompt;
            voteController.agileHub = self.agileHub;
        }
        //UINavigationController *navController = (UI)
    }
}
#pragma mark - segue handling

#pragma mark + SPPBaseEntityDelegate
- (void)entityDidChange: (SPPBaseEntity *) entity {
    
}

- (void)entityDidChange: (SPPBaseEntity *) entity list: (NSMutableArray *) list {
    if (entity == room) {
        if (list == room.connectedUsers) {
            [_cvUsers reloadData];
        } else if (list == room.itemsToVote) {
            [_tvVotes reloadData];
        }
    }
}
#pragma mark - SPPBaseEntityDelegate

#pragma mark + SPPAgileHubVoteDelegate
- (void)agileHubDidUserVote: (NSDictionary *) userVoteData {
    [room hubDidUserVote:userVoteData];
}

- (void)agileHubDidVoteFinish: (NSDictionary *) voteData {
    [room hubDidVoteFinish:voteData];
}

- (void)agileHubDidVoteOpen: (NSDictionary *) voteData {
    [room hubDidVoteOpen:voteData];
}

- (void)agileHubDidVoteClose: (NSDictionary *) voteData {
    [room hubDidVoteClose:voteData];
}
#pragma mark - SPPAgileHubVoteDelegate

#pragma mark + SPPRoomDelegate
- (void)room:(SPPRoom *)room DidVote:(SPPVote *)vote withUserVote:(SPPUserVote *)userVote {
    for (int i=0; i<self.room.connectedUsers.count; i++) {
        SPPUserViewCell *cell = (SPPUserViewCell*)[_cvUsers cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (!cell) continue;
        [cell DidVote:vote withUserVote:userVote];
    }
}

- (void) room:(SPPRoom *) room DidVoteFinish: (SPPVote*) vote {
    for (int i=0; i<self.room.connectedUsers.count; i++) {
        SPPUserViewCell *cell = (SPPUserViewCell*)[_cvUsers cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (!cell) continue;
        [cell DidVoteFinish:vote];
    }
}

- (void) room:(SPPRoom *) room DidVoteOpen: (SPPVote*) vote {
    for (int i=0; i<self.room.connectedUsers.count; i++) {
        SPPUserViewCell *cell = (SPPUserViewCell*)[_cvUsers cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (!cell) continue;
        [cell DidVoteOpen:vote];
    }
}

- (void) room:(SPPRoom *) room DidVoteClose: (SPPVote*) vote {
    for (int i=0; i<self.room.connectedUsers.count; i++) {
        SPPUserViewCell *cell = (SPPUserViewCell*)[_cvUsers cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (!cell) continue;
        [cell DidVoteClose:vote];
    }
}

#pragma mark - SPPRoomDelegate


@end
