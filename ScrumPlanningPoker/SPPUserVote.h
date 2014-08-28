//
//  SPPVoteUser.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseEntity.h"

FOUNDATION_EXPORT NSString *const SPPUserVote_onChanged;

@interface SPPUserVote : SPPBaseEntity

@property NSInteger mark;
@property NSInteger userId;

@end