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
    //SRHubConnection *roomConnection;
    SPPProperties *properties;
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
    properties=[SPPProperties sharedProperties];
    self.navigationItem.prompt=[NSString stringWithFormat:@"%@ / %@", properties.server, properties.selectedRoom];
    //[_cvUsers registerClass:[SPPUserViewCell class] forCellWithReuseIdentifier: userCellIdentifier];
    SPPAgileHub *hub=properties.agileHub;
    hub.roomDelegate = self;
    [hub JoinRoom:properties.selectedRoom];
//    [self lockView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actJoin:(id)sender {
//    [roomHub invoke:@"joinRoom" withArgs:@[properties.room, properties.sessionId] completionHandler:^(id response) {
//        NSLog(@"%@", response);
//    }];
}

#pragma mark SPPAgileHubRoomDelegate
- (void)onJoinRoom: (SPPRoom *)room
{
    NSLog(@"%@", room.name);
    [_cvUsers reloadData];
}

#pragma makr -


#pragma mark UICollectionViewDataSource
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
        //cell.frame = CGRectMake(0, 0, 150, 120);
        //cell.backgroundColor = [UIColor redColor];
        //cell = [[UICollectionViewCell alloc] init];
                //initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
        //[cell setImage: @"ffffff"];
    //NSDictionary *roomItem = [[rooms objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    //cell.textLabel.text = [roomItem objectForKey:@"Name"];
    //cell.detailTextLabel.text = [roomItem objectForKey:@"Description"];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
#pragma mark -

@end
