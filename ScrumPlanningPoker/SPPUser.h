//
//  SPPUser.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseEntity.h"

FOUNDATION_EXPORT NSString *const SPPUser_onChanged;

@interface SPPUser : SPPBaseEntity

@property NSString *name;
@property BOOL isAdmin;
@property NSMutableArray *privileges;

@end
