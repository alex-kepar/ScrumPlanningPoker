//
//  RoomViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "RoomViewController.h"
#import "VoteViewController.h"
#import "SPPUserViewCell.h"
#import "SPPVoteViewCell.h"
#import "SPPVote.h"
#import "RoomViewNotifications.h"

@interface RoomViewController ()
@end

@implementation RoomViewController

@synthesize room;
@synthesize currentUser;
@synthesize promptRoot;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.prompt = [NSString stringWithFormat:@"%@/%@", promptRoot, room.name];
    self.navigationItem.title = @"Votes";
    self.outRoomButton.room = room;
    self.cvUsers.isEditMode = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyRoom_onChanged:)
                                                 name:SPPRoom_onChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyRoom_onUserLeft:)
                                                 name:SPPRoom_onUserLeft
                                               object:nil];
}

#pragma mark - Users list handling (SPPEditableCollectionViewDataSource)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return room.connectedUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPPUserViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
    if (cell != nil)
    {
        [cell initializeWithUser:room.connectedUsers[indexPath.row] andVote:nil andCurrentUser:currentUser];
    }
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView canEditCellAtIndexPath:(NSIndexPath *)indexPath {
    SPPUser *user = room.connectedUsers[indexPath.row];
    return currentUser.isAdmin
        && room.isActive
        && user.entityId != currentUser.entityId;
}

- (void)collectionView:(UICollectionView *)collectionView shouldDeleteItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Delete user");
    [room removeUser:room.connectedUsers[indexPath.row]];
}

#pragma mark - Vote list handling (UITableViewDataSource)
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return currentUser.isAdmin && room.isActive;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Delete vote");
    [room removeVote:room.itemsToVote[indexPath.row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return room.itemsToVote.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPPVoteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoteCell" forIndexPath:indexPath];
    if (cell != nil) {
        [cell initializeWithVote:room.itemsToVote[indexPath.row] forCurrentUser:currentUser forRoom:room];
        __weak RoomViewController *weakSelf = self;
        cell.voteAction = ^(SPPVote *vote) {
            RoomViewController *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            //[strongSelf selectVote:vote];
            [strongSelf performSegueWithIdentifier:@"VoteSeque" sender:vote];
        };
        cell.changeStateAction = ^(SPPVote *vote) {
            RoomViewController *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            //[strongSelf selectVote:vote];
            if (!vote.isOpened) {
                [vote open];
            } else if (!vote.isFinished) {
                [vote closeWithOveralValue:-1];
            } else if (vote) {
                [strongSelf performSegueWithIdentifier:@"ChangeVoteStateSeque" sender:vote];
            }
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPPVote *selectedVote = room.itemsToVote[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomView_onChangeSelectedVote
                                                        object:self
                                                      userInfo:@{@"vote": selectedVote}];
}

#pragma mark - segue handling
//- (id) _findSuperviewForObject:(id)obj KindOfClass:(Class)classResult {
//    id superview = [obj superview];
//    if ([superview isKindOfClass:classResult] ||
//        superview == nil) {
//        return superview;
//    }
//    return [self _findSuperviewForObject:superview KindOfClass:classResult];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BOOL voteSegue = [segue.identifier isEqualToString:@"VoteSeque"];
    BOOL changeVoteStateSeque = [segue.identifier isEqualToString:@"ChangeVoteStateSeque"];
    if (voteSegue ||
        changeVoteStateSeque) {
        if ([segue.destinationViewController isKindOfClass:[VoteViewController class]] &&
            [sender isKindOfClass:[SPPVote class]]) {
            SPPVote *gotVote = sender;
            VoteViewController *voteController = (VoteViewController *)segue.destinationViewController;
            voteController.promptRoot = self.navigationItem.prompt;
            voteController.vote = gotVote;
            if (voteSegue) {
                voteController.title = @"Vote";
                voteController.action = ^(SPPVote *vote, NSInteger voteValue) {
                    [vote doVote:voteValue];
                };
            } else {
                NSInteger sumValue = 0;
                for (SPPUserVote *userVote in gotVote.votedUsers) {
                    sumValue += userVote.mark;
                }
                voteController.defaultValue = sumValue / gotVote.votedUsers.count;
                voteController.title = @"Overall vote";
                voteController.action = ^(SPPVote *vote, NSInteger voteValue) {
                    [vote closeWithOveralValue:voteValue];
                };
            }
        }
    }
}

#pragma mark - messages handling
-(void) notifyRoom_onChanged:(NSNotification*) notification {
    if (notification.object == room) {
        BOOL isVotesNeedRepoad = YES;
        BOOL isUsersNeedRepoad = YES;
        if (notification.userInfo) {
            id list = [notification.userInfo valueForKey:@"list"];
            isVotesNeedRepoad = list == room.itemsToVote;
            isUsersNeedRepoad = list == room.connectedUsers;
        }
        if (isVotesNeedRepoad) {
            [self.tvVotes reloadData];
        }
        if (isUsersNeedRepoad) {
            [self.cvUsers reloadData];
        }
    }
}

-(void) notifyRoom_onUserLeft:(NSNotification*) notification {
    if (notification.object == room) {
        if (notification.userInfo) {
            SPPUser *deletedUser = [notification.userInfo valueForKey:@"deletedUser"];
            if (deletedUser.entityId == currentUser.entityId) {
                [self showMessage:@"Other user removed your user from this room." withTitle:room.name];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

@end
