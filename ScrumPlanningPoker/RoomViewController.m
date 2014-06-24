//
//  RoomViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "RoomViewController.h"
#import "SPPProperties.h"
#import "SignalR.h"
#import "SPPUser.h"
#import "SPPUserViewCell.h"

@interface RoomViewController ()
{
    SPPProperties* properties;
    SPPAgileHub* hub;
}
@end

@implementation RoomViewController

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
    properties = [SPPProperties sharedProperties];
    hub = properties.agileHub;
    self.navigationItem.prompt = [NSString stringWithFormat:@"%@/%@", properties.connection.server, properties.room.name];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    hub.roomDelegate = self;
    [hub joinRoom:properties.room.name];
    [self lockView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [hub leaveRoom:properties.room.name];
    if (hub.roomDelegate == self) {
        hub.roomDelegate = Nil;
    }
}

#pragma mark + SPPAgileHubRoomDelegate
- (void)agileHubJoinRoom: (SPPRoom *)room
{
    NSLog(@"%@", room.name);
    [_cvUsers reloadData];
    UIImage *img = [UIImage imageNamed:@"RoomOpened.png"];
    UIImageView *imgV = [[UIImageView alloc] initWithImage:img];
    imgV.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:imgV];
    self.navigationItem.rightBarButtonItem = barItem;
    [self unLockView];
}

- (void)agileHubJoinUser: (SPPUser *) user toRoom: (SPPRoom *) room
{
    NSLog(@"Joined user %@", user.name);
    [_cvUsers reloadData];
}

- (void)agileHubLeftUser: (SPPUser *) user theRoom: (SPPRoom *) room
{
    NSLog(@"Left user %@", user.name);
    [_cvUsers reloadData];
}

#pragma makr - SPPAgileHubRoomDelegate

#pragma mark + UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return properties.room.connectedUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPPUserViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
    
    if(cell!=nil)
    {
        SPPUser *user=properties.room.connectedUsers[indexPath.row];
        cell.userName.text=user.name;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
#pragma mark - UICollectionViewDataSource

@end
