//
//  RoomsViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseViewController.h"
#import "SPPAgileHubFacade.h"

@interface SelectRoomViewController : SPPBaseViewController <UITableViewDataSource, UITableViewDelegate>

//@property SPPAgileHub *agileHub;
@property NSString *promptRoot;
//@property NSArray *roomListDto;
@property SPPAgileHubFacade *agileHubFacade;

@property (weak, nonatomic) IBOutlet UITableView *tvRooms;
@end
