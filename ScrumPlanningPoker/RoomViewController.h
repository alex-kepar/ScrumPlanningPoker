//
//  RoomViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseViewController.h"
#import "SPPRoom.h"
#import "SPPUser.h"
#import "SPPRoomButton.h"
#import "SPPEditableCollectionView.h"

@interface RoomViewController : SPPBaseViewController <UICollectionViewDataSource, SPPEditableCollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property SPPRoom *room;
@property SPPUser *currentUser;
@property NSString *promptRoot;

@property (weak, nonatomic) IBOutlet SPPEditableCollectionView *cvUsers;
@property (weak, nonatomic) IBOutlet UITableView *tvVotes;
@property (weak, nonatomic) IBOutlet SPPRoomButton *outRoomButton;

@end
