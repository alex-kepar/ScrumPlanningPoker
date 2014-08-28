//
//  ConnectViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/3/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPBaseViewController.h"
#import "SPPWebService.h"
#import "SPPAgileHubFacade.h"

@interface ConnectViewController : SPPBaseViewController <UITextFieldDelegate, SPPWebServiceDelegate, SPPAgileHubFacadeConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtServer;
@property (weak, nonatomic) IBOutlet UITextField *txtLogin;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

- (IBAction)actConnect:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end
