//
//  RoomViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseViewController.h"
#import "SignalR.h"
#import "SPPAgileHub.h"
#import "SPPRoom.h"

//@interface PushupListViewController : UICollectionViewController <UICollectionViewDataSource>

@interface RoomViewController : SPPBaseViewController <SRConnectionDelegate, SPPAgileHubRoomDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, SPPBaseEntityDelegate, SPPAgileHubVoteDelegate, SPPRoomDelegate>

@property SPPRoom *room;
@property NSString *promptRoot;
@property SPPAgileHub *agileHub;

@property (weak, nonatomic) IBOutlet UICollectionView *cvUsers;
@property (weak, nonatomic) IBOutlet UITableView *tvVotes;

@end
