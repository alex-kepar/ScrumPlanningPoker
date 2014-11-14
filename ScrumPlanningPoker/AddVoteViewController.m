//
//  AddVoteViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 11/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "AddVoteViewController.h"

@interface AddVoteViewController ()
@property (weak, nonatomic) IBOutlet UITextView *outText;

@end

@implementation AddVoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.prompt = self.promptRoot;
    self.navigationItem.title = @"Add vote";
    
    //self.outText.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.outText becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self deregisterFromKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actButtonDone:(UIBarButtonItem *)sender {
    if (self.action) {
        self.action(self.outText.text);
    }
    //[self.outText resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Keyboard handling
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)deregisterFromKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect bkgndRect = self.view.frame;
    bkgndRect.size.height -= kbSize.height;
    [self.view setFrame:bkgndRect];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect bkgndRect = self.view.frame;
    bkgndRect.size.height += kbSize.height;
    [self.view setFrame:bkgndRect];
}


@end
