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
    SPPVote *selectedVote;
}
@end

@implementation RoomViewController

@synthesize room;
@synthesize promptRoot;
//@synthesize agileHub;

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
    //agileHub.roomDelegate = self;
    //agileHub.voteDelegate = self;
    room.delegate = self;
    //room.roomDelegate = self;
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

#pragma mark + UICollectionViewDataSource
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    return 1;
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return room.connectedUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPPUserViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
    if (cell != nil)
    {
        [cell initializeWithUser:room.connectedUsers[indexPath.row] andVote:selectedVote];
    }
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    return nil;
//}
#pragma mark - UICollectionViewDataSource


#pragma mark + UITableViewDataSource

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

#pragma mark - UITableViewDataSource

#pragma mark + UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedVote = [self.room.itemsToVote objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SPPRoomChangeSelectedVoteNotification" object:self.room userInfo:@{@"selectedVote": [self.room.itemsToVote objectAtIndex:indexPath.row]}];
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
            //voteController.room = self.room;
            voteController.vote = [self.room.itemsToVote objectAtIndex:indexPath.row];
            voteController.promptRoot = self.navigationItem.prompt;
            //voteController.agileHub = self.agileHub;
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

//#pragma mark + SPPAgileHubRoomDelegate
//
//- (void)agileHubDidJoinUser: (NSDictionary *) userData {
//    [room addUserUseData:userData];
//}
//
//- (void)agileHubDidLeaveUser: (NSDictionary *) userData {
//    [room removeUserUseData:userData];
//}
//
//- (void)agileHubDidChangeRoom: (NSDictionary *) roomData {
//    [room updateFromDictionary:roomData];
//}
//
//#pragma makr - SPPAgileHubRoomDelegate
//
//#pragma mark + SPPAgileHubVoteDelegate
//- (void)agileHubDidUserVote: (NSDictionary *) userVoteData {
//    [room hubDidUserVote:userVoteData];
//}
//
//- (void)agileHubDidVoteFinish: (NSDictionary *) voteData {
//    [room hubDidVoteFinish:voteData];
//}
//
//- (void)agileHubDidVoteOpen: (NSDictionary *) voteData {
//    [room hubDidVoteOpen:voteData];
//}
//
//- (void)agileHubDidVoteClose: (NSDictionary *) voteData {
//    [room hubDidVoteClose:voteData];
//}
//#pragma mark - SPPAgileHubVoteDelegate


@end
