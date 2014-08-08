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
#import "RoomViewNotifications.h"
#import "SPPAgileHubNotifications.h"

@interface RoomViewController ()
{
    NSDictionary *selectedVoteDto;
}
@end

@implementation RoomViewController

@synthesize roomDto;
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
    self.navigationItem.prompt = [NSString stringWithFormat:@"%@/%@", promptRoot, [roomDto valueForKey:@"Name"]];
}


#pragma mark + UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[roomDto valueForKey:@"ConnectedUsers"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPPUserViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
    if (cell != nil)
    {
        [cell initializeWithUserDto:((NSArray*)[roomDto objectForKey:@"ConnectedUsers"])[indexPath.row] andVoteDto:selectedVoteDto];
    }
    return cell;
}
#pragma mark - UICollectionViewDataSource


#pragma mark + UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[roomDto objectForKey:@"ItemsToVote"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPPVoteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoteCell" forIndexPath:indexPath];
    if (cell != nil) {
        [cell initializeWithVoteDto:((NSArray*)[roomDto objectForKey:@"ItemsToVote"])[indexPath.row]];
    }
    return cell;
}

#pragma mark - UITableViewDataSource

#pragma mark + UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedVoteDto = ((NSArray*)[roomDto valueForKey:@"ItemsToVote"])[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomView_onChangeSelectedVote object:self userInfo:@{@"voteDto": selectedVoteDto}];
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
    return selectedVoteDto != nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"VoteSeque"]) {
        if ([segue.destinationViewController isKindOfClass:[VoteViewController class]] && selectedVoteDto != nil) {
            //NSIndexPath *indexPath = [self.tvVotes indexPathForSelectedRow];
            VoteViewController *voteController = (VoteViewController *)segue.destinationViewController;
            voteController.promptRoot = self.navigationItem.prompt;
            voteController.voteDelegate = self;
            voteController.voteDto = selectedVoteDto;
        }
    }
}
#pragma mark - segue handling


#pragma mark + VoteViewControllerDelegate
- (void) Vote:(NSString*) voteId doVote: (NSString*) voteValue {
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPAgileHub_Vote
                                                        object:self
                                                      userInfo:@{@"roomName":[roomDto valueForKey:@"Name"],
                                                                 @"voteId":voteId,
                                                                 @"voteValue": voteValue}];
}
#pragma mark - VoteViewControllerDelegate

@end
