//
//  RoomViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "RoomViewController.h"
#import "SPPUserViewCell.h"
#import "SPPVoteViewCell.h"
#import "SPPVote.h"
#import "RoomViewNotifications.h"
#import "VoteViewController.h"

@interface RoomViewController ()
{
    SPPVote *selectedVote;
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
        [cell initializeWithUser:room.connectedUsers[indexPath.row] andVote:selectedVote];
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
    }
    return cell;
}

#pragma mark - UITableViewDataSource

#pragma mark + UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedVote = room.itemsToVote[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomView_onChangeSelectedVote
                                                        object:self
                                                      userInfo:@{@"vote": selectedVote}];
}
#pragma mark - UITableViewDelegate

#pragma mark + segue handling

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"VoteSeque"]) {
        NSIndexPath *indexPath;
        if ([sender isKindOfClass:[UIButton class]]) {
            //UITableViewCell *clickedCell = (UITableViewCell*)[[sender superview] superview];
            UITableViewCell *clickedCell = (UITableViewCell*)[[[sender superview] superview] superview];
            indexPath = [self.tvVotes indexPathForCell:clickedCell];
            //indexPath = [self.tvVotes indexOfAccessibilityElement:sender];
            //} else {
            //    indexPath = [self.tvVotes indexPathForSelectedRow];
        }
        if (indexPath != nil) {
            if(indexPath != [self.tvVotes indexPathForSelectedRow]) {
                [self.tvVotes selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                [self tableView:self.tvVotes didSelectRowAtIndexPath:[self.tvVotes indexPathForSelectedRow]];
            }
        }
    }
    return selectedVote != nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"VoteSeque"]) {
        if ([segue.destinationViewController isKindOfClass:[VoteViewController class]] && selectedVote != nil) {
            //NSIndexPath *indexPath = [self.tvVotes indexPathForSelectedRow];
            VoteViewController *voteController = (VoteViewController *)segue.destinationViewController;
            voteController.promptRoot = self.navigationItem.prompt;
            //voteController.voteDelegate = self;
            voteController.vote = selectedVote;
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
