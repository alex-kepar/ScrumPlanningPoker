//
//  SPPRoomViewCell.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/20/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPUserViewCell.h"
#import "RoomViewNotifications.h"
#import "SPPUserVote.h"
#import "SPPAnimationFactory.h"

@interface SPPUserViewCell()
@property (strong, nonatomic) CATransition *animation;
@end

@implementation SPPUserViewCell {
    SPPUser *user;
    SPPVote *vote;
//    NSInteger voteValue;
}

- (CATransition*)animation {
    if (!_animation) {
        _animation = [SPPAnimationFactory editAnimation];
    }
    return _animation;
}

-(void) initializeWithUser:(SPPUser*)initUser andVote:(SPPVote*)initVote {
    user = initUser;
    vote = initVote;
    [self redrawWithAnimation:NO];
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyUser_onChanged:)
                                                     name:SPPUser_onChanged
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyVote_onChanged:)
                                                     name:SPPVote_onChanged
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(roomDidChangeSelectedVote:)
                                                     name:RoomView_onChangeSelectedVote
                                                   object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) notifyUser_onChanged:(NSNotification*) notification {
    SPPUser *getUser = notification.object;
    if (user != nil && getUser != nil && getUser.entityId == user.entityId) {
        user = getUser;
        [self redrawWithAnimation:NO];
    }
}

-(void) notifyVote_onChanged:(NSNotification*) notification {
    SPPVote *getVote = notification.object;
    if (vote != nil && getVote != nil && getVote.entityId == vote.entityId) {
        vote = getVote;
        [self redrawWithAnimation:YES];
    }
}

-(void) redrawWithAnimation:(BOOL)isAnimate  {
    NSString *text = @"no vote";
    NSInteger voteValue = -1;
    if (vote != nil && user != nil) {
        for (SPPUserVote *userVote in [vote.votedUsers reverseObjectEnumerator]) {
            if (user.entityId == userVote.userId) {
                voteValue = userVote.mark;
                break;
            }
        }
        if (vote.isOpened) {
            if (voteValue<0) {
                text = @"?";
            } else {
                if (vote.isFinished) {
                    text = [NSString stringWithFormat:@"%ld", (long)voteValue];
                } else {
                    text = @"voted";
                }
            }
        } else {
            if (voteValue>=0) {
                text = [NSString stringWithFormat:@"%ld", (long)voteValue];
            }
        }
    }
    if (![self.lVote.text isEqualToString:text]) {
        if (isAnimate) {
            [self.lVote.layer addAnimation:self.animation forKey:@"111kCATransitionFade"];
        }
        self.lVote.text = text;
    }
    self.userName.text = user.name;
}

-(void) roomDidChangeSelectedVote:(NSNotification*) notification {
    vote = notification.userInfo[@"vote"];
    [self redrawWithAnimation:NO];
}

@end
