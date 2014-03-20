//
//  SPPRoom.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPRoom.h"
#import "SPPUser.h"
#import "SPPVote.h"

@implementation SPPRoom

@synthesize isActive;
@synthesize name;
@synthesize description;
@synthesize connectedUsers;
@synthesize itemsToVote;

+ (instancetype)SPPRoomWithDataDictionary: (NSDictionary*) initData
{
    return [[self alloc] initWithDataDictionary:initData];
}

- (instancetype)initWithDataDictionary:(NSDictionary *)initData
{
    self = [super init];
    if (self)
    {
        isActive = [[initData objectForKey:@"Active"] boolValue];
        name = [initData objectForKey:@"Name"];
        description = [initData objectForKey:@"Description"];
        
        NSArray *usersData = [initData objectForKey:@"ConnectedUsers"];
        connectedUsers = [[NSMutableArray alloc] initWithCapacity:usersData.count];
        for (int i = 0; i<usersData.count; i++) {
            connectedUsers[i]=[SPPUser SPPUserWithDataDictionary:usersData[i]];
        }

        NSArray *votesData = [initData objectForKey:@"ItemsToVote"];
        itemsToVote = [[NSMutableArray alloc] initWithCapacity:votesData.count];
        for (int i = 0; i<itemsToVote.count; i++) {
            itemsToVote[i]=[SPPVote SPPVoteWithDataDictionary:votesData[i]];
        }
    }
    return self;
}

@end
