//
//  SPPVoteViewCell.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPVoteViewCell.h"
#import "SPPAgileHubNotifications.h"

@implementation SPPVoteViewCell {
    NSInteger voteId;
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

-(void) initializeWithVoteDto:(NSDictionary*) initVoteDto {
    voteId = [[initVoteDto objectForKey:@"Id"] integerValue];
    [self redrawVoteDto:initVoteDto];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agileHub_VoteChanged:) name:SPPAgileHubRoom_onVoteOpened object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agileHub_VoteChanged:) name:SPPAgileHubRoom_onVoteClosed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agileHub_VoteChanged:) name:SPPAgileHubRoom_onVoteFinished object:nil];
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

- (void) redrawVoteDto: (NSDictionary*) voteDto {
    _lContent.text = [voteDto objectForKey:@"Content"];
    BOOL isOpened = [[voteDto objectForKey:@"Opened"] boolValue];
    BOOL isFinished = [[voteDto objectForKey:@"Finished"] boolValue];
    if (isOpened) {
        _lState.text = @"Opened";
    } else {
        _lState.text = @"Closed";
    }
    if (isFinished) {
        if (isOpened) {
            _lOveralVote.text = @"?";
        } else {
            _lOveralVote.text = [NSString stringWithFormat:@"%d", [[voteDto objectForKey:@"OverallMark"] integerValue]];
        }
        
    } else {
        if (isOpened) {
            _lOveralVote.text = @"voting";
        } else {
            _lOveralVote.text = @"no vote";
        }
    }
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

-(void) agileHub_VoteChanged:(NSNotification*) notification {
    NSDictionary *voteDto = notification.userInfo[@"voteDto"];
    if (voteId == [[voteDto objectForKey:@"Id"] integerValue]) {
        [self redrawVoteDto:voteDto];
    }
}

@end
