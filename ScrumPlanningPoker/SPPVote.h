//
//  SPPVote.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseEntity.h"
#import "SPPUserVote.h"

FOUNDATION_EXPORT NSString *const SPPVote_onChanged;

@class SPPVote;
@protocol SPPVoteDelegate<NSObject>
@optional
- (void)SPPVote:(SPPVote*) vote doVote: (NSInteger) voteValue;
@end

@interface SPPVote : SPPBaseEntity

@property NSString *content;
@property NSInteger roomId;
@property BOOL isClosed;
@property BOOL isOpened;
@property BOOL isFinished;
@property NSInteger overallMark;
@property NSMutableArray *votedUsers;
@property NSObject *owner;

@property (nonatomic, assign) id <SPPVoteDelegate> voteDelegate;

- (SPPUserVote*) userDidVoteWithData:(NSDictionary*)userVoteData;
- (void) doVote: (NSInteger) voteValue;

@end
