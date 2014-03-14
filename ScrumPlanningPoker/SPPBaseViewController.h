//
//  BaseViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/11/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPPBaseViewController : UIViewController

-(void) lockView;
-(void) unLockView;
-(void) showMessage: (NSString*) message withTitle: (NSString*) title;

@end
