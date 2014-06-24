//
//  ConnectViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/3/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "ConnectViewController.h"
#import "SPPProperties.h"

@interface ConnectViewController ()

@end

@implementation ConnectViewController
{
    SPPProperties *properties;
}

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
    self.navigationItem.title=@"Connection";
    properties = [SPPProperties sharedProperties];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    properties.connection.connectionDelegate = self;
    properties.agileHub.connectionDelegate = self;
    [properties.agileHub Disconnect];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (properties.connection.connectionDelegate == self) {
        properties.connection.connectionDelegate = Nil;
    }
    if (properties.agileHub.connectionDelegate == self) {
        properties.agileHub.connectionDelegate = Nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actConnect:(id)sender {
    [self lockView];
    [properties.connection ConnectTo:[_txtServer text] Login:[_txtLogin text] Password:[_txtPassword text]];
    
    
    /*NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/Handlers/LoginHandler.ashx", [_txtServer text]]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    NSData* passwordData=[[_txtPassword text] dataUsingEncoding:NSUTF8StringEncoding];
    NSString* passwordEncode=[[passwordData base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData* messageData=[[NSString stringWithFormat:@"%@:%@", [_txtLogin text], passwordEncode] dataUsingEncoding:NSUTF8StringEncoding];
    
    [request addValue:[NSString stringWithFormat:@"Basic %@", [messageData base64EncodedStringWithOptions:0]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            [self unLockView];
            if (error == nil)
            {
                NSInteger status = [(NSHTTPURLResponse *)response statusCode];
                if(status == 200)
                {
                    properties = [SPPProperties sharedProperties];
                    NSArray* cookies = [NSURLSession sharedSession].configuration.HTTPCookieStorage.cookies;
                    NSUInteger cookieIndex=[cookies indexOfObjectPassingTest:^BOOL(id cookieId, NSUInteger idx, BOOL *stop)
                                            {
                                                if([[(NSHTTPCookie *)cookieId name] isEqualToString:@".ASPXAUTH"])
                                                {
                                                    *stop=YES;
                                                    return YES;
                                                }
                                                return NO;
                                            }];
                    if (cookieIndex != NSNotFound)
                    {
                        properties.userToken = [(NSHTTPCookie *)cookies[cookieIndex] value];
                        properties.server = _txtServer.text;
                        properties.hubConnection = nil;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSegueWithIdentifier:@"ShowRooms" sender:self];
                        });
                        //dispatch_async(dispatch_get_main_queue(), ^{
                        //    [self performSegueWithIdentifier:@"TestSegue" sender:self];
                        //});
                    }
                    else
                    {
                        [self showMessage:@"Authorization not passed" withTitle:@"Error connection"];
                    }
                }
                else
                {
                    [self showMessage:[NSString stringWithFormat:@"%@", [NSHTTPURLResponse localizedStringForStatusCode: status ]] withTitle:@"Error connection"];
                }
            }
            else
            {
                [self showMessage:[NSString stringWithFormat:@"%@", [error localizedDescription]] withTitle:@"Error connection"];
            }
        }];
    [task resume];*/
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
    [connection GetRoomList];
}

-(void) connection:(SPPConnection *)connection didReceiveError:(NSError *)error
{
    [self unLockView];
    [self showMessage:[NSString stringWithFormat:@"%@", [error localizedDescription]] withTitle:@"Error connection"];
}

-(void) connection:(SPPConnection *)connection didReceiveRoomList:(NSArray *)data
{
    properties.roomList = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (int i = 0; i < data.count; i++) {
        properties.roomList[i] = [SPPRoom SPPRoomWithDataDictionary:data[i]];
    }
    [properties.agileHub ConnectTo:connection.server];
}
#pragma mark - SPPConnectionDelegate

#pragma mark + SPPAgileHubConnectionDelegate
- (void)agileHubDidOpen:(SPPAgileHub *) agileHub
{
    [self unLockView];
    [self performSegueWithIdentifier:@"ShowRooms" sender:self];
}
- (void)agileHub:(SPPAgileHub *) agileHub didReceiveError:(NSString *)error
{
    [self unLockView];
    [self showMessage:error withTitle:@"Error connection"];
}
#pragma mark - SPPAgileHubConnectionDelegate

@end
