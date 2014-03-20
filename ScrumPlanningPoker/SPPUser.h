//
//  SPPUser.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/17/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPPUser : NSObject

@property NSInteger userId;
@property NSString *name;
@property BOOL isAdmin;
@property NSMutableArray *privileges;

+ (instancetype)SPPUserWithDataDictionary: (NSDictionary*) initData;
- (instancetype)initWithDataDictionary:(NSDictionary *)initData;

@end
