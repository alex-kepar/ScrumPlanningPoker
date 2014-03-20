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

//@interface PushupListViewController : UICollectionViewController <UICollectionViewDataSource>

@interface RoomViewController : SPPBaseViewController <SRConnectionDelegate, SPPAgileHubRoomDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

- (IBAction)actJoin:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *cvUsers;

@end
