//
//  SPPVoteUser.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/18/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseEntity.h"

@interface SPPUserVote : SPPBaseEntity

@property NSInteger mark;
@property NSInteger userId;
@property NSObject *owner;

@end
