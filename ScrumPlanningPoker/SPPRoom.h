//
//  SPPRoom.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseEntity.h"
#import "SPPVote.h"

FOUNDATION_EXPORT NSString *const SPPRoom_onChanged;

@class SPPRoom;

@protocol SPPRoomDelegate<NSObject>
@optional
- (void)SPPRoom:(SPPRoom *)room withVote:(SPPVote *)vote doVote:(NSInteger)voteValue;
- (void)SPPRoom:(SPPRoom *)room openVote:(SPPVote *)vote;
- (void)SPPRoom:(SPPRoom *)room closeVote:(SPPVote *)vote withOveralValue:(NSInteger)overalValue;
- (void)SPPRoom:(SPPRoom *)room changeState:(BOOL)newState;
@end

@interface SPPRoom : SPPBaseEntity <SPPVoteDelegate>

@property (nonatomic, weak)id <SPPRoomDelegate> roomDelegate;

@property NSString* name;
@property NSString* roomDescription;
@property BOOL isActive;
@property NSMutableArray* connectedUsers;
@property NSMutableArray* itemsToVote;

+ (instancetype) SPPRoomWithDataDictionary:(NSDictionary*)initData;
- (void) updateUser:(NSDictionary*)userDto;
- (void) removeUser:(NSDictionary*)userDto;
- (void) userVote:(NSDictionary*)userVoteDto;
- (void) updateVote:(NSDictionary*)voteDto;

- (void)changeState:(BOOL)newState;

@end