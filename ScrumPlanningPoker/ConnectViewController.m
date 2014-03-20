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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actConnect:(id)sender {
    [self lockView];
    //NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://vinw2617/WebSignalR/Handlers/LoginHandler.ashx"]];
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/WebSignalR/Handlers/LoginHandler.ashx", [_txtServer text]]];
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
                    SPPProperties *properties = [SPPProperties sharedProperties];
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
    [task resume];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

@end
