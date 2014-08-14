//
//  SPPVoteViewCell.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPVote.h"

@interface SPPVoteViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lContent;
@property (weak, nonatomic) IBOutlet UILabel *lState;
@property (weak, nonatomic) IBOutlet UILabel *lOveralVote;
@property (weak, nonatomic) IBOutlet UIButton *bVote;

-(void) initializeWithVote:(SPPVote*) initVote;

@end
