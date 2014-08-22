//
//  SPPVoteViewCell.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPVote.h"

typedef void(^SPPVoteViewCellVoteActionBlock)(SPPVote *vote);

@interface SPPVoteViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lContent;
//@property (weak, nonatomic) IBOutlet UILabel *lState;
@property (weak, nonatomic) IBOutlet UILabel *lOveralVote;
@property (weak, nonatomic) IBOutlet UIButton *bVote;
@property (weak, nonatomic) IBOutlet UISwitch *swOpened;
- (IBAction)actVote:(UIButton *)sender;
- (IBAction)actChangeState:(UISwitch *)sender;
@property (copy, nonatomic) SPPVoteViewCellVoteActionBlock voteAction;
@property (copy, nonatomic) SPPVoteViewCellVoteActionBlock changeStateAction;

- (void)initializeWithVote:(SPPVote*)initVote;
//- (void)setVoteAction:(SPPVoteViewCellVoteAction)newVoteAction;
@end
