//
//  SPPRoomViewCell.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/20/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPUserViewCell.h"

@implementation SPPUserViewCell {
    NSInteger voteValue;
    SPPUser *user;
    SPPVote *vote;
}

-(void) initializeWithUser:(SPPUser*) initUser andVote:(SPPVote*) initVote {
    user = initUser;
    vote = initVote;
    _userName.text = user.name;
    voteValue = [self calculateValueOfVote];
    [self redrawVote];
}

-(NSInteger) calculateValueOfVote {
    NSInteger newValue = -1;
    if (vote && user) {
        for (SPPUserVote *userVote in [vote.votedUsers reverseObjectEnumerator]) {
            if (userVote.userId == user.entityId) {
                newValue = userVote.mark;
                break;
            }
        }
    }
    return newValue;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomDidVote:) name:@"SPPRoomDidVoteNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomDidVoteFinish:) name:@"SPPRoomDidVoteFinishNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomDidVoteOpen:) name:@"SPPRoomDidVoteOpenNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomDidVoteClose:) name:@"SPPRoomDidVoteCloseNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomDidChangeSelectedVote:) name:@"SPPRoomChangeSelectedVoteNotification" object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) redrawVote {
    NSString *text = @"no vote";
    if (vote.isOpened) {
        if (voteValue<0) {
            text = @"?";
        } else {
            if (vote.isFinished) {
                text = [NSString stringWithFormat:@"%d", voteValue];
            } else {
                text = @"voted";
            }
        }
    } else {
        if (voteValue>=0) {
            text = [NSString stringWithFormat:@"%d", voteValue];
        }
    }
    _lVote.text = text;
}

-(void) roomDidVote:(NSNotification*) notification {
    SPPVote *getVote = notification.userInfo[@"vote"];
    SPPUserVote *getUserVote = notification.userInfo[@"userVote"];
    if (vote && vote.entityId == getVote.entityId && user.entityId == getUserVote.userId) {
        voteValue = getUserVote.mark;
        [self redrawVote];
    }
}

-(void) roomDidVoteFinish:(NSNotification*) notification {
    SPPVote *getVote = notification.userInfo[@"vote"];
    if (vote && vote.entityId == getVote.entityId) {
        [self redrawVote];
    }
}

-(void) roomDidVoteOpen:(NSNotification*) notification {
    SPPVote *getVote = notification.userInfo[@"vote"];
    if (vote && vote.entityId == getVote.entityId) {
        voteValue = -1;
        [self redrawVote];
    }
}

-(void) roomDidVoteClose:(NSNotification*) notification {
    SPPVote *getVote = notification.userInfo[@"vote"];
    if (vote && vote.entityId == getVote.entityId) {
        [self redrawVote];
    }
}

-(void) roomDidChangeSelectedVote:(NSNotification*) notification {
    vote = notification.userInfo[@"selectedVote"];
    voteValue = [self calculateValueOfVote];
    [self redrawVote];
}

@end
