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
}

@synthesize user = _user;
@synthesize selectedVote = _selectedVote;

-(void) setUser:(SPPUser *)user {
    if (_user != user) {
        _user = user;
        [self redrawUser];
        [self setValueOfVote];
    }
}

-(SPPUser*) user {
    return _user;
}

-(void) setSelectedVote:(SPPVote *)selectedVote {
    _selectedVote = selectedVote;
    [self setValueOfVote];
}

-(SPPVote*) selectedVote {
    return _selectedVote;
}


-(void) setValueOfVote {
    voteValue = -1;
    if (self.selectedVote && self.user) {
        //for (int i = self.selectedVote.votedUsers.count - 1; i<=0; i--) {
        //    SPPUserVote *userVote = self.selectedVote.votedUsers[i];
        //    if (userVote.userId == self.user.entityId) {
        //        voteValue = userVote.mark;
        //        break;
        //    }
        //}
        for (SPPUserVote *userVote in [self.selectedVote.votedUsers reverseObjectEnumerator]) {
            if (userVote.userId == self.user.entityId) {
                voteValue = userVote.mark;
                break;
            }
        }
    }
    [self redrawVote];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) redrawUser {
    _userName.text = self.user.name;
}

-(void) redrawVote {
    NSString *text = @"no vote";
    if (self.selectedVote.isOpened) {
        if (voteValue<0) {
            text = @"?";
        } else {
            if (self.selectedVote.isFinished) {
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

-(void) DidVote:(SPPVote *)vote withUserVote:(SPPUserVote *)userVote {
    if (self.selectedVote && self.selectedVote.entityId == vote.entityId && self.user.entityId == userVote.userId) {
        voteValue = userVote.mark;
        [self redrawVote];
    }
}

-(void) DidVoteOpen:(SPPVote *)vote {
    if (self.selectedVote && self.selectedVote.entityId == vote.entityId) {
        voteValue = -1;
        [self redrawVote];
    }
}

-(void) DidVoteClose:(SPPVote *)vote {
    if (self.selectedVote && self.selectedVote.entityId == vote.entityId) {
        [self redrawVote];
    }
}

-(void) DidVoteFinish:(SPPVote *)vote {
    if (self.selectedVote && self.selectedVote.entityId == vote.entityId) {
        [self redrawVote];
    }
}

@end
