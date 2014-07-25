//
//  RoomsViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseViewController.h"
#import "SPPAgileHub.h"
#import "SPPRoom.h"

@interface SelectRoomViewController : SPPBaseViewController <UITableViewDataSource, UITableViewDelegate, SPPAgileHubStateDelegate, SPPRoomDelegate>

@property SPPAgileHub *agileHub;
@property NSString *promptRoot;
@property NSArray *roomListData;

@property (weak, nonatomic) IBOutlet UITableView *tvRooms;
@end
