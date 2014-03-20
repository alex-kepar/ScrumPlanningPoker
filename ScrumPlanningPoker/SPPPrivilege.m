//
//  SPPPrivilege.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/17/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPPrivilege.h"

@implementation SPPPrivilege

@synthesize privilegeId;
@synthesize name;
@synthesize description;

+ (instancetype) SPPPrivilegeWithDataDictionary: (NSDictionary*) initData
{
    return [[self alloc] initWithDataDictionary:initData];
}

- (instancetype)initWithDataDictionary:(NSDictionary *)initData
{
    self = [super init];
    if (self)
    {
        privilegeId = [[initData objectForKey:@"Id"] intValue];
        name = [initData objectForKey:@"Name"];
        description = [initData objectForKey:@"Description"];
    }
    return self;
}

@end
