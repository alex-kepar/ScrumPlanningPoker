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
    //NSDictionary *voteDto;
}

//@synthesize vote = _vote;

//- (void) setVote:(SPPVote *)vote {
//    if (_vote != vote) {
//        if (_vote) {
//            if (_vote.delegate == self) {
//                _vote.delegate = nil;
//            }
//        }
//        _vote = vote;
//        if (_vote) {
//            _vote.delegate = self;
//            [self redrawVote];
//        }
//    }
//}
//
//- (SPPVote *) vote {
//    return _vote;
//}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

- (IBAction)actChangeVoteState:(UISwitch *)sender {
    if (sender.isOn) {
        
    } else {
        //[self p performSegueWithIdentifier:@"ShowRooms" sender:self];
    }
}

- (IBAction)actDidEndOnExit:(UISwitch *)sender {
}

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void) removeFromSuperview {
//    [super removeFromSuperview];
//    self.vote = nil;
//}

//- (void) redrawVote {
//    _lContent.text = self.vote.content;
//    if (self.vote.isOpened) {
//        _lState.text = @"Opened";
//    } else {
//        _lState.text = @"Closed";
//    }
//    if (self.vote.isFinished) {
//        if (self.vote.isOpened) {
//            _lOveralVote.text = @"?";
//        } else {
//            _lOveralVote.text = [NSString stringWithFormat:@"%d", self.vote.overallMark];
//        }
//        
//    } else {
//        if (self.vote.isOpened) {
//            _lOveralVote.text = @"voting";
//        } else {
//            _lOveralVote.text = @"no vote";
//        }
//    }
//}

- (void) redrawCell {
    self.lContent.text = vote.content;
    /*if (vote.isOpened) {
        if (vote.isFinished) {
            self.lState.text = @"Finished";
        } else {
            self.lState.text = @"Opened";
        }
    } else {
        self.lState.text = @"Closed";
    }*/
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

//- (void)entityDidChange: (SPPBaseEntity *) entity {
//    if (entity == self.vote) {
//        [self redrawVote];
//    }
//}
//
//- (void)entityDidChange: (SPPBaseEntity *) entity list: (NSMutableArray *) list {
//    if (entity == self.vote) {
//        [self redrawVote];
//    }
//}

-(void) notifyVote_onChanged:(NSNotification*) notification {
    SPPVote *getVote = notification.object;
    if (vote != nil && getVote != nil && getVote.entityId == vote.entityId) {
        vote = getVote;
        [self redrawCell];
    }

}

@end
