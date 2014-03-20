//
//  SPPVote.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPPVote : NSObject

@property NSString* content;

+ (instancetype)SPPVoteWithDataDictionary: (NSDictionary*) initData;
- (instancetype)initWithDataDictionary:(NSDictionary *)initData;

@end
