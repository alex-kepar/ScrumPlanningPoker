//
//  AddVoteViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 11/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseViewController.h"
#import "SPPVote.h"

typedef void(^AddVoteViewControllerActionBlock)(NSString *voteContent);

@interface AddVoteViewController : SPPBaseViewController

@property (copy, nonatomic) AddVoteViewControllerActionBlock action;
@property NSString *promptRoot;
@property SPPVote *vote;

@end
