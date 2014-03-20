//
//  SPPUser.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/17/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPUser.h"
#import "SPPPrivilege.h"

@implementation SPPUser

@synthesize userId;
@synthesize name;
@synthesize isAdmin;
@synthesize privileges;


+ (instancetype) SPPUserWithDataDictionary: (NSDictionary*) initData
{
    return [[self alloc] initWithDataDictionary:initData];
}

- (instancetype)initWithDataDictionary:(NSDictionary *)initData
{
    self = [super init];
    if (self)
    {
        userId = [[initData objectForKey:@"Id"] integerValue];
        name = [initData objectForKey:@"Name"];
        isAdmin = [[initData objectForKey:@"IsAdmin"] boolValue];
        NSArray *privilegeData = [initData objectForKey:@"Privileges"];
        
        privileges = [[NSMutableArray alloc] initWithCapacity:privilegeData.count];
        for (int i = 0; i<privilegeData.count; i++) {
            privileges[i]=[SPPPrivilege SPPPrivilegeWithDataDictionary:privilegeData[i]];
        }
      
        //_message = initMessage;
        //NSLog(@"Id=%@", );
        //NSLog(@"Name=%@", [userDto objectForKey:@"Name"]);
        //NSLog(@"isAdmin=%@", [userDto objectForKey:@"IsAdmin"]);
        //NSLog(@"Privileges=%@", [userDto objectForKey:@"Privileges"]);
        //NSArray *privilegesList = [userDto objectForKey:@"Privileges"];
    }
    return self;
}


@end
