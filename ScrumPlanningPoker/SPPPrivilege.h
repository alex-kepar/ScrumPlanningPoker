//
//  SPPPrivilege.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseEntity.h"

FOUNDATION_EXPORT NSString *const SPPPrivilege_onChanged;

@interface SPPPrivilege : SPPBaseEntity

@property NSString *name;
@property NSString *description;

@end