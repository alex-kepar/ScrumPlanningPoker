//
//  SPPVote.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPVote.h"

@implementation SPPVote

@synthesize content;

+ (instancetype)SPPVoteWithDataDictionary: (NSDictionary*) initData
{
    return [[self alloc] initWithDataDictionary:initData];
}

- (instancetype)initWithDataDictionary:(NSDictionary *)initData
{
    self = [super init];
    if (self)
    {
        content = [initData objectForKey:@"Content"];
//        isActive = [[initData objectForKey:@"Active"] boolValue];
//
//        description = [initData objectForKey:@"Description"];
//        
//        NSArray *usersData = [initData objectForKey:@"ConnectedUsers"];
//        connectedUsers = [[NSMutableArray alloc] initWithCapacity:usersData.count];
//        for (int i = 0; i<usersData.count; i++) {
//            connectedUsers[i]=[SPPUser SPPUserWithDataDictionary:connectedUsers[i]];
//        }
//        
//        NSArray *votesData = [initData objectForKey:@"ItemsToVote"];
//        itemsToVote = [[NSMutableArray alloc] initWithCapacity:votesData.count];
//        for (int i = 0; i<itemsToVote.count; i++) {
//            connectedUsers[i]=[SPPUser SPPUserWithDataDictionary:connectedUsers[i]];
//        }
    }
    return self;
}


@end
