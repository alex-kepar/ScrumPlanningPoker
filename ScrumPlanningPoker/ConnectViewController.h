//
//  ConnectViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/3/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignalR.h"
#import "SPPBaseViewController.h"

@interface ConnectViewController : SPPBaseViewController <UITextFieldDelegate>
- (IBAction)actConnect:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtServer;
@property (weak, nonatomic) IBOutlet UITextField *txtLogin;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
- (IBAction)backgroundTap:(id)sender;

@end
