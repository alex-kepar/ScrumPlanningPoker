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
{
    //SPPVote *selectedVote;
}
@end

@implementation RoomViewController

@synthesize room;
@synthesize promptRoot;

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
    self.navigationItem.prompt = [NSString stringWithFormat:@"%@/%@", promptRoot, room.name];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyRoom_onChanged:)
                                                 name:SPPRoom_onChanged
                                               object:nil];
}


#pragma mark + UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return room.connectedUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPPUserViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
    if (cell != nil)
    {
        [cell initializeWithUser:room.connectedUsers[indexPath.row] andVote:nil];//selectedVote];
    }
    return cell;
}
#pragma mark - UICollectionViewDataSource


#pragma mark + UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return room.itemsToVote.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPPVoteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoteCell" forIndexPath:indexPath];
    if (cell != nil) {
        [cell initializeWithVote:room.itemsToVote[indexPath.row]];
        cell.voteAction = ^(SPPVote *vote) {
            [self selectVote:vote];
            [self performSegueWithIdentifier:@"VoteSeque" sender:vote];
        };
        cell.changeStateAction = ^(SPPVote *vote) {
            [self selectVote:vote];
            if (!vote.isOpened) {
                [vote open];
            } else if (!vote.isFinished) {
                [vote closeWithOveralValue:-1];
            } else if (vote) {
                [self performSegueWithIdentifier:@"ChangeVoteStateSeque" sender:vote];
            }
        };
    }
    return cell;
}

- (void)selectVote:(SPPVote*)vote {
    NSInteger row = [room.itemsToVote indexOfObjectPassingTest:^BOOL(SPPVote* item, NSUInteger idx, BOOL *stop) {
        return (item.entityId == vote.entityId);
    }];
    if (row != NSNotFound) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
        if (index != [self.tvVotes indexPathForSelectedRow]) {
            [self.tvVotes selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.tvVotes didSelectRowAtIndexPath:[self.tvVotes indexPathForSelectedRow]];
        }
    }
}

#pragma mark - UITableViewDataSource

#pragma mark + UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPPVote *selectedVote = room.itemsToVote[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomView_onChangeSelectedVote
                                                        object:self
                                                      userInfo:@{@"vote": selectedVote}];
}
#pragma mark - UITableViewDelegate

#pragma mark + segue handling

- (id) _findSuperviewForObject:(id)obj KindOfClass:(Class)classResult {
    id superview = [obj superview];
    if ([superview isKindOfClass:classResult] ||
        superview == nil) {
        return superview;
    }
    return [self _findSuperviewForObject:superview KindOfClass:classResult];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BOOL voteSegue = [segue.identifier isEqualToString:@"VoteSeque"];
    BOOL changeVoteStateSeque = [segue.identifier isEqualToString:@"ChangeVoteStateSeque"];
    if (voteSegue ||
        changeVoteStateSeque) {
        if ([segue.destinationViewController isKindOfClass:[VoteViewController class]] &&
            [sender isKindOfClass:[SPPVote class]]) {
            SPPVote *vote = sender;
            VoteViewController *voteController = (VoteViewController *)segue.destinationViewController;
            voteController.promptRoot = self.navigationItem.prompt;
            voteController.content = vote.content;
            if (voteSegue) {
                voteController.action = ^(NSInteger voteValue) {
                    [vote doVote:voteValue];
                };
            } else {
                voteController.action = ^(NSInteger voteValue) {
                    [vote closeWithOveralValue:voteValue];
                };
            }
        }
    }
}
#pragma mark - segue handling

-(void) notifyRoom_onChanged:(NSNotification*) notification {
    if (notification.object == room && notification.userInfo) {
        id list = [notification.userInfo valueForKey:@"list"];
        if (list == room.connectedUsers) {
            [self.cvUsers reloadData];
        } else if (list == room.itemsToVote) {
            [self.tvVotes reloadData];
        }
    }
}

@end
