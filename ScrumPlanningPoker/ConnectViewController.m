//
//  ConnectViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/3/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "ConnectViewController.h"
#import "SPPUser.h"
#import "SPPRoom.h"
#import "SelectRoomViewController.h"

@implementation ConnectViewController
{
    SPPConnection *webConnection;
    SPPAgileHub *agileHub;
    SPPUser *logUser;
    NSArray *roomListData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title=@"Connection";
    webConnection = [[SPPConnection alloc] init];
    agileHub = [[SPPAgileHub alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    webConnection.connectionDelegate = self;
    agileHub.connectDelegate = self;
    agileHub.stateDelegate = nil;
    agileHub.roomDelegate = nil;
    [agileHub Disconnect];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //if (connection.connectionDelegate == self) {
    //    connection.connectionDelegate = nil;
    //}
    //if (agileHub.connectDelegate == self) {
    //    agileHub.connectDelegate = nil;
    //}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actConnect:(id)sender {
    [self lockView];
    [webConnection ConnectTo:[_txtServer text] Login:[_txtLogin text] Password:[_txtPassword text]];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark + SPPConnectionDelegate
-(void) connectionDidOpen:(SPPConnection *)connection
{
    [agileHub ConnectTo:connection.server];
}

-(void) connection:(SPPConnection *)connection didReceiveRoomList:(NSArray *)data
{
    roomListData = data;
    [self unLockView];
    [self performSegueWithIdentifier:@"ShowRooms" sender:self];
}

-(void) connection:(SPPConnection *)connection didReceiveError:(NSError *)error
{
    [self unLockView];
    [self showMessage:[NSString stringWithFormat:@"%@", [error localizedDescription]] withTitle:@"Error connection"];
}
#pragma mark - SPPConnectionDelegate

#pragma mark + SPPAgileHubConnectDelegate

- (void)agileHubDidOpen:(SPPAgileHub *) agileHub {
    [webConnection GetRoomList];
}

- (void)agileHubDidClose:(SPPAgileHub *) agileHub {
    logUser = nil;
}

- (void)agileHub:(SPPAgileHub *) agileHub didLogUser:(NSDictionary *)userData {
    logUser = [SPPUser SPPBaseEntityWithDataDictionary:userData];
}

- (void)agileHub:(SPPAgileHub *) agileHub didReceiveError:(NSString *)error {
    [self unLockView];
    [self showMessage:error withTitle:@"Error connection"];
}
#pragma mark - SPPAgileHubConnectDelegate

#pragma mark + segue handling
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowRooms"]) {
        if ([segue.destinationViewController isKindOfClass:[SelectRoomViewController class]]) {
            SelectRoomViewController *selectRoomController = (SelectRoomViewController *)segue.destinationViewController;
            selectRoomController.agileHub = agileHub;
            selectRoomController.promptRoot = webConnection.server;
            //selectRoomController.roomList = roomList;
            selectRoomController.roomListData = roomListData;
        }
    }
}
#pragma mark + segue handling

@end
