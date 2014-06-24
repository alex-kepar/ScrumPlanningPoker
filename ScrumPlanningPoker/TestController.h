//
//  TestController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/28/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignalR.h"


@interface TestController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)actJoinRoom:(id)sender;
- (IBAction)actLeaveRoom:(id)sender;
- (IBAction)actTest:(id)sender;
@property (strong, nonatomic, readwrite) SRHubConnection *connection;
@property (strong, nonatomic, readwrite) SRHubProxy *hub;
@property (strong, nonatomic, readwrite) NSMutableArray *data;

@end
