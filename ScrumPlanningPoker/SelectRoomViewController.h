//
//  RoomsViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseViewController.h"
#import "SignalR.h"

@interface SelectRoomViewController : SPPBaseViewController <UITableViewDataSource, UITableViewDelegate, SRConnectionDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tvRooms;
@end
