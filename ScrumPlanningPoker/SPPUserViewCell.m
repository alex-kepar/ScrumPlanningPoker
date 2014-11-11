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
#import "CALayer+XibConfiguration.h"

@interface SPPUserViewCell()
@property (strong, nonatomic) CATransition *animation;
@end

@implementation SPPUserViewCell {
    SPPUser *user;
    SPPVote *vote;
    SPPUser *currentUser;
    
//    NSInteger voteValue;
}

- (CATransition*)animation {
    if (!_animation) {
        _animation = [SPPAnimationFactory editAnimation];
    }
    return _animation;
}

- (void)initializeWithUser:(SPPUser*)initUser andVote:(SPPVote*)initVote andCurrentUser:(SPPUser*)initCurrentUser {
    user = initUser;
    vote = initVote;
    currentUser = initCurrentUser;
    [self initializeLayerForView:self.contentView];

    [self redrawWithAnimation:NO];
}

- (void)initializeLayerForView:(UIView*)view {
    CGFloat alpha = user.isAdmin ? 1 : 0.5;
    view.layer.borderUIColor = (currentUser.entityId == user.entityId) ? [UIColor colorWithRed:0 green:1 blue:0 alpha:alpha] : [UIColor colorWithWhite:0 alpha:alpha];
    view.layer.borderWidth = user.isAdmin ? 1 : 0.5;
    view.layer.cornerRadius = 6;
    view.layer.masksToBounds = NO;
    [view setClipsToBounds:YES];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        //layer.cornerRadius = 6
        //layer.masksToBounds = NO
        //layer.borderWidth = 0.5
        //layer.borderUIColor = lightGrayColor;
        
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
            [self.lVote.layer addAnimation:self.animation forKey:@"kCATransitionFade"];
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
