//
//  SPPUser.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/17/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPBaseEntity.h"

@interface SPPUser : SPPBaseEntity

@property NSString *name;
@property BOOL isAdmin;
@property NSMutableArray *privileges;

@end
