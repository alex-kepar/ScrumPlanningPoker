//
//  SPPRoom.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPBaseEntity.h"
//#import "SPPUser.h"
#import "SPPVote.h"

@class SPPRoom;
@protocol SPPRoomDelegate<NSObject>
@optional
- (void) room:(SPPRoom *) room DidVote: (SPPVote*) vote withUserVote: (SPPUserVote*) userVote;
- (void) room:(SPPRoom *) room DidVoteFinish: (SPPVote*) vote;
- (void) room:(SPPRoom *) room DidVoteOpen: (SPPVote*) vote;
- (void) room:(SPPRoom *) room DidVoteClose: (SPPVote*) vote;
@end

@interface SPPRoom : SPPBaseEntity

@property (nonatomic, assign)id <SPPRoomDelegate> roomDelegate;

@property NSString* name;
@property NSString* description;
@property BOOL isActive;
@property NSMutableArray* connectedUsers;
@property NSMutableArray* itemsToVote;

- (void) addUserUseData:(NSDictionary*)userData;
- (void) removeUserUseData:(NSDictionary*)userData;
- (void) addVoteUseData:(NSDictionary*)voteData;

- (void) hubDidUserVote:(NSDictionary*) userVoteData;
- (void) hubDidVoteFinish: (NSDictionary *) voteData;
- (void) hubDidVoteOpen: (NSDictionary *) voteData;
- (void) hubDidVoteClose: (NSDictionary *) voteData;
@end
