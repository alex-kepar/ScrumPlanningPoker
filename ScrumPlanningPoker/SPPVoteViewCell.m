//
//  SPPVoteViewCell.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPVoteViewCell.h"

@implementation SPPVoteViewCell {
    SPPVote *vote;
//    SPPVoteViewCellVoteAction voteAction;
}

@synthesize voteAction;
@synthesize changeStateAction;

-(void) initializeWithVote:(SPPVote*)initVote {
    vote = initVote;
    [self redrawCell];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyVote_onChanged:)
                                                     name:SPPVote_onChanged
                                                   object:nil];
    }
    return self;
}

-(void) dealloc {
    //voteAction = Nil;
    //changeStateAction = Nil;
    //[voteAction release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) redrawCell {
    self.lContent.text = vote.content;
    if (vote.isOpened) {
        if (vote.isFinished) {
            self.lOveralVote.text = @"finished";
        } else {
            self.lOveralVote.text = @"voting";
        }
    } else {
        if (vote.isFinished) {
            self.lOveralVote.text = [NSString stringWithFormat:@"%d", vote.overallMark];
        } else {
            self.lOveralVote.text = @"no vote";
        }
    }
    self.swOpened.on = vote.isOpened;
    self.bVote.enabled = vote.isOpened && !vote.isFinished;
}

-(void) notifyVote_onChanged:(NSNotification*) notification {
    SPPVote *getVote = notification.object;
    if (vote != nil && getVote != nil && getVote.entityId == vote.entityId) {
        vote = getVote;
        [self redrawCell];
    }

}

- (IBAction)actVote:(UIButton *)sender {
    if (voteAction) {
        voteAction(vote);
    }
}

- (IBAction)actChangeState:(UISwitch *)sender {
    [self.swOpened setOn:vote.isOpened];
    if (changeStateAction) {
        changeStateAction(vote);
    }
}

//- (void)setVoteAction:(SPPVoteViewCellVoteAction)newVoteAction {
//    voteAction = newVoteAction;
//}

@end
