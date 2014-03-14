 //
//  ConnectViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/3/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "ConnectViewController.h"
#import "SignalR.h"
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actConnect:(id)sender {
    [self lockView];
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/WebSignalR/Handlers/LoginHeader.ashx", [_txtServer text]]];
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
                    [SPPProperties sharedProperties].server = _txtServer.text;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSegueWithIdentifier:@"loginSegue" sender:self];
                    });
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

    //hub=[connection createHubProxy:@""];
    
}

/*
-(void) queryResponceData: NSData *data responce: NSURLResponse *responce error: NSError *error
{
    NSInteger status = [response statusCode];
    if(status == 200)
    {
        NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [_outText setText:[NSString stringWithFormat:@"%@ - %i", responseString, status]];
        
        NSArray* cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:[NSURL URLWithString:@""]];
        
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
            NSHTTPCookie *cookie = cookies[cookieIndex];
            NSLog(@"%@", cookie.name);
            
            
            NSURLRequest *requestUserList=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://vinw2617/WebSignalR/api/room/GetRooms"]];
            NSData *dataUserList = [NSURLConnection sendSynchronousRequest:requestUserList returningResponse:&response error:&error];
            NSArray *userList = [NSJSONSerialization JSONObjectWithData:dataUserList options:0 error:&error];
            
            for (NSDictionary *user in userList)
            {
                NSLog(@"Id=%@", [user objectForKey:@"Id"]);
                NSLog(@"Name=%@", [user objectForKey:@"Name"]);
                NSLog(@"Description=%@", [user objectForKey:@"Description"]);
                NSLog(@"Active=%d", [[user objectForKey:@"Active"] boolValue]);
            }
            
            //            // Connect to the service
            //            connection = [SRHubConnection connectionWithURL: @"http://vinw2617/WebSignalR"];
            //            [connection addValue:[NSString stringWithFormat:@".ASPXAUTH=%@", cookie.value] forHTTPHeaderField:@"Cookie" ];
            //            // Create a proxy to the chat service
            //            hub = [connection createHubProxy:@"agileHub"];
            //            //[hub on:@"addMessage" perform:self selector:@selector(addMessage:message:)];
            //            [connection setDelegate:self];
            //            // Start the connection
            //            [connection start];
            
            
        }
    }
    else
    {
        [_outText setText:[NSString stringWithFormat:@"%@", [NSHTTPURLResponse localizedStringForStatusCode: status ]]];
    }
   
}
*/

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

@end
