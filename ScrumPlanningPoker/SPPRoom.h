//
//  SPPRoom.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseEntity.h"
#import "SPPVote.h"
#import "SPPUser.h"

FOUNDATION_EXPORT NSString *const SPPRoom_onChanged;
FOUNDATION_EXPORT NSString *const SPPRoom_onUserLeft;

@class SPPRoom;

@protocol SPPRoomDelegate<NSObject>
@optional
- (void)SPPRoom:(SPPRoom *)room withVote:(SPPVote *)vote doVote:(NSInteger)voteValue;
- (void)SPPRoom:(SPPRoom *)room openVote:(SPPVote *)vote;
- (void)SPPRoom:(SPPRoom *)room closeVote:(SPPVote *)vote withOveralValue:(NSInteger)overalValue;
- (void)SPPRoom:(SPPRoom *)room changeState:(BOOL)newState;

- (void)SPPRoom:(SPPRoom *)room removeUser:(SPPUser *)user;
- (void)SPPRoom:(SPPRoom *)room removeVote:(SPPVote *)vote;
@end

@interface SPPRoom : SPPBaseEntity <SPPVoteDelegate>

@property (nonatomic, weak)id <SPPRoomDelegate> roomDelegate;

@property NSString* name;
@property NSString* roomDescription;
@property BOOL isActive;
@property NSMutableArray* connectedUsers;
@property NSMutableArray* itemsToVote;

+ (instancetype) SPPRoomWithDataDictionary:(NSDictionary*)initData;
- (void)didUpdateUser:(NSDictionary*)userDto;
- (void)didRemoveUser:(NSDictionary*)userDto;
- (void)didUserVote:(NSDictionary*)userVoteDto;
- (void)didUpdateVote:(NSDictionary*)voteDto;

- (void)changeState:(BOOL)newState;

- (void)removeUser:(SPPUser*)user;
- (void)removeVote:(SPPVote*)vote;
@end