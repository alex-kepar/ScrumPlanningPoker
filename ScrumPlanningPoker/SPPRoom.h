//
//  SPPRoom.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>

struct SPPRoomResult
{
    BOOL isActive;
    BOOL isHostMaster;
};

@interface SPPRoom : NSObject

@property BOOL isActive;
@property NSString* name;
@property NSString* description;
@property NSMutableArray* connectedUsers;
@property NSMutableArray* itemsToVote;

+ (instancetype)SPPRoomWithDataDictionary: (NSDictionary*) initData;
- (instancetype)initWithDataDictionary:(NSDictionary *)initData;

@end
