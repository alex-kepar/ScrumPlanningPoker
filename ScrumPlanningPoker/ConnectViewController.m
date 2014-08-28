//
//  ConnectViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/3/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "ConnectViewController.h"
#import "SelectRoomViewController.h"
#import "SPPAgileHubNotifications.h"

@implementation ConnectViewController
{
    SPPWebService *webService;
    SPPAgileHubFacade *agileHubFacade;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title=@"Connection";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    webService = nil;
    if (agileHubFacade) {
        [self lockView];
        [agileHubFacade disconnect];
        agileHubFacade = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actConnect:(id)sender {
    [self lockView];
    webService = [[SPPWebService alloc] init];
    webService.delegate = self;
    [webService connectTo:[_txtServer text] Login:[_txtLogin text] Password:[_txtPassword text]];
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
- (void)webService:(SPPWebService*)service didConnected:(NSString*)server;
{
    [service getRoomList];
}

-(void) webService:(SPPWebService *)service didReceiveRoomList:(NSArray *)data
{
    agileHubFacade = [SPPAgileHubFacade SPPAgileHubFacadeWithRoomList:data
                                                           serverName:service.server];
    agileHubFacade.connectionDelegate = self;
    [agileHubFacade connect];
}

-(void) webService:(SPPWebService *)service didReceiveError:(NSError *)error
{
    [self unlockView];
    [self showMessage:[NSString stringWithFormat:@"%@", [error localizedDescription]] withTitle:@"Error connection"];
}

#pragma mark - SPPConnectionDelegate

#pragma mark + segue handling
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self unlockView];
    if ([segue.identifier isEqualToString:@"ShowRooms"]) {
        if ([segue.destinationViewController isKindOfClass:[SelectRoomViewController class]]) {
            SelectRoomViewController *selectRoomController = (SelectRoomViewController *)segue.destinationViewController;
            SPPAgileHubFacade *facade = sender;
            selectRoomController.promptRoot = facade.serverName;
            selectRoomController.agileHubFacade = facade;
        }
    }
}
#pragma mark + segue handling

#pragma mark + SPPAgileHubFacadeConnectionDelegate
- (void)agileHubFacade:(SPPAgileHubFacade *)hub Connection:(SRConnection *)connection didReceiveError:(NSError *)error {
    [self unlockView];
    [self showMessage:[NSString stringWithFormat:@"%@", [error localizedDescription]] withTitle:@"Error connection"];
    if (error.code != 0) {
        [self.navigationController popToViewController:self animated:YES];
    }
}

- (void)agileHubFacade:(SPPAgileHubFacade*)hub ConnectionDidClose:(SRConnection*)connection {
    [self unlockView];
    agileHubFacade = nil;
}


- (void)agileHubFacade:(SPPAgileHubFacade*)hub HubSessionDidOpenByUser:(SPPUser*)user {
    [self performSegueWithIdentifier:@"ShowRooms" sender:hub];
}

- (void)agileHubFacade:(SPPAgileHubFacade*)hub HubDidReceiveError:(NSError*)error {
    [self unlockView];
    [self showMessage:[NSString stringWithFormat:@"%@", [error localizedDescription]] withTitle:@"Hub error"];
    
}
#pragma mark - SPPAgileHubFacadeConnectionDelegate

@end
