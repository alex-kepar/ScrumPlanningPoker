//
//  SPPRoomViewCell.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/20/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPUserViewCell.h"
#import "RoomViewNotifications.h"
#import "SPPAgileHubNotifications.h"

@implementation SPPUserViewCell {
    NSInteger userId;
    NSInteger voteId;

    NSInteger voteValue;
    BOOL voteIsOpened;
    BOOL voteIsFinished;
}

-(void) initializeWithUserDto:(NSDictionary*) initUserDto andVoteDto:(NSDictionary*) initVoteDto {
    userId = [[initUserDto valueForKey:@"Id"] integerValue];
    voteId = [[initVoteDto valueForKey:@"Id"] integerValue];
    _userName.text = [initUserDto valueForKey:@"Name"];
    [self redrawVote:initVoteDto withVoteValue:-1];
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(roomDidUserVote:)
                                                     name:SPPAgileHubRoom_onUserVoted
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(roomDidVoteChanged:)
                                                     name:SPPAgileHubRoom_onVoteFinished
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(roomDidVoteChanged:)
                                                     name:SPPAgileHubRoom_onVoteOpened
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(roomDidVoteChanged:)
                                                     name:SPPAgileHubRoom_onVoteClosed
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

-(void) redrawVote: (NSDictionary*) voteDto {
    [self redrawVote:voteDto withVoteValue:voteValue];
}

-(void) redrawVote: (NSDictionary*) voteDto withVoteValue: (NSInteger) setVoteValue {
    NSString *text = @"no vote";
    if (voteDto != nil) {
        if (setVoteValue == -1) {
            for (NSDictionary *userVoteDto in [[voteDto valueForKey:@"VotedUsers"] reverseObjectEnumerator]) {
                if (userId == [[userVoteDto valueForKey:@"Id"] integerValue]) {
                    setVoteValue = [[userVoteDto valueForKey:@"OverallMark"] integerValue];
                    break;
                }
            }
        }
        voteIsOpened = [[voteDto valueForKey:@"Opened"] boolValue];
        voteIsFinished = [[voteDto valueForKey:@"Finished"] boolValue];
    }
    voteValue = setVoteValue;
    if (voteIsOpened) {
        if (voteValue<0) {
            text = @"?";
        } else {
            if (voteIsFinished) {
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

-(void) roomDidUserVote:(NSNotification*) notification {
    NSDictionary *userVoteDto = notification.userInfo[@"userVoteDto"];
    if (voteId == [[userVoteDto objectForKey:@"VoteItemId"] integerValue] &&
        userId == [[userVoteDto objectForKey:@"UserId"] integerValue]) {
        [self redrawVote:nil withVoteValue:[[userVoteDto objectForKey:@"Mark"] integerValue]];
    }
}

-(void) roomDidVoteChanged:(NSNotification*) notification {
    NSDictionary *getVoteDto = notification.userInfo[@"voteDto"];
    if (voteId == [[getVoteDto objectForKey:@"Id"] integerValue]) {
        [self redrawVote:getVoteDto];
    }
}

-(void) roomDidChangeSelectedVote:(NSNotification*) notification {
    NSDictionary *getVoteDto = notification.userInfo[@"voteDto"];
    voteId = [[getVoteDto objectForKey:@"Id"] integerValue];
    [self redrawVote:getVoteDto withVoteValue:-1];
}

@end
