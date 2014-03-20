//
//  SPPPrivilege.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/17/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPPPrivilege : NSObject

@property int privilegeId;
@property NSString *name;
@property NSString *description;

+ (instancetype) SPPPrivilegeWithDataDictionary: (NSDictionary*) initData;
- (instancetype)initWithDataDictionary:(NSDictionary *)initData;

@end
