//
//  BaseViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/11/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseViewController.h"

@interface SPPBaseViewController ()
{
    UIActivityIndicatorView *lockIndicator;
}
@end

@implementation SPPBaseViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"********** Controller '%@' deallocated.", [self class]);

}

- (void)lockView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (lockIndicator == nil)
        {
            lockIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            lockIndicator.hidesWhenStopped = YES;
            [self.view addSubview:lockIndicator];
        }
        lockIndicator.center = self.view.center;
        [lockIndicator startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self.view endEditing:YES];
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        //NSLog(@"%@", @"lock");
    });
}

- (void)unlockView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (lockIndicator != nil)
        {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [lockIndicator stopAnimating];
            //NSLog(@"%@", @"unlock");
        }
    });
}

- (void)showMessage: (NSString*) message withTitle: (NSString*) title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show]; //@"OK1", @"OK2", nil];
    });
}
@end
