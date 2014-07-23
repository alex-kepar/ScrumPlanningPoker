//
//  SPPVoteViewCell.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPVoteViewCell.h"

@implementation SPPVoteViewCell

@synthesize vote = _vote;

- (void) setVote:(SPPVote *)vote {
    if (_vote != vote) {
        if (_vote) {
            if (_vote.delegate == self) {
                _vote.delegate = nil;
            }
        }
        _vote = vote;
        if (_vote) {
            _vote.delegate = self;
            [self redrawVote];
        }
    }
}

- (SPPVote *) vote {
    return _vote;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) removeFromSuperview {
    [super removeFromSuperview];
    self.vote = nil;
}

- (void) redrawVote {
    _lContent.text = self.vote.content;
    if (self.vote.isOpened) {
        _lState.text = @"Opened";
    } else {
        _lState.text = @"Closed";
    }
    if (self.vote.isFinished) {
        if (self.vote.isOpened) {
            _lOveralVote.text = @"?";
        } else {
            _lOveralVote.text = [NSString stringWithFormat:@"%d", self.vote.overallMark];
        }
        
    } else {
        if (self.vote.isOpened) {
            _lOveralVote.text = @"voting";
        } else {
            _lOveralVote.text = @"no vote";
        }
    }
}


- (void)entityDidChange: (SPPBaseEntity *) entity {
    if (entity == self.vote) {
        [self redrawVote];
    }
}

- (void)entityDidChange: (SPPBaseEntity *) entity list: (NSMutableArray *) list {
    if (entity == self.vote) {
        [self redrawVote];
    }
}

@end
