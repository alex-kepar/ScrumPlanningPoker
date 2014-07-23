//
//  SPPVote.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPBaseEntity.h"
#import "SPPUserVote.h"


@interface SPPVote : SPPBaseEntity

@property NSString *content;
@property NSInteger roomId;
@property BOOL isClosed;
@property BOOL isOpened;
@property BOOL isFinished;
@property NSInteger overallMark;
@property NSMutableArray *votedUsers;
@property NSObject *owner;

- (SPPUserVote*) userDidVoteWithData:(NSDictionary*)userVoteData;

@end
