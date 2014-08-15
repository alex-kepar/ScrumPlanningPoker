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
- (void)SPPRoom:(SPPRoom*)room withVote:(SPPVote*)vote doVote:(NSInteger)voteValue;
- (void)SPPRoom:(SPPRoom*)room openVote:(SPPVote*)vote;
- (void)SPPRoom:(SPPRoom*)room closeVote:(SPPVote*)vote withOveralValue:(NSInteger)overalValue;
@end

@interface SPPRoom : SPPBaseEntity //<SPPAgileHubRoomDelegate>

@property (nonatomic, assign)id <SPPRoomDelegate> roomDelegate;

@property NSString* name;
@property NSString* description;
@property BOOL isActive;
@property NSMutableArray* connectedUsers;
@property NSMutableArray* itemsToVote;

+ (instancetype) SPPRoomWithDataDictionary:(NSDictionary*)initData;
- (void) updateUser:(NSDictionary*)userDto;
- (void) removeUser:(NSDictionary*)userDto;
- (void) userVote:(NSDictionary*)userVoteDto;
- (void) updateVote: (NSDictionary*)voteDto;

//@property (nonatomic, assign) id <SPPAgileHubRoomMethodsDelegate> agileHubDelegate;

//@property (nonatomic, assign) id <SPPRoomDelegate> roomDelegate;


//- (void) doVote

//- (void) addUserUseData:(NSDictionary*)userData;
//- (void) removeUserUseData:(NSDictionary*)userData;
//- (void) addVoteUseData:(NSDictionary*)voteData;

//- (void) hubDidUserVote:(NSDictionary*) userVoteData;
//- (void) hubDidVoteFinish: (NSDictionary *) voteData;
//- (void) hubDidVoteOpen: (NSDictionary *) voteData;
//- (void) hubDidVoteClose: (NSDictionary *) voteData;

//- (void)agileHubDidJoinUser: (NSDictionary *) userData;
//- (void)agileHubDidLeaveUser: (NSDictionary *) userData;
//- (void)agileHubDidChangeRoom: (NSDictionary *) roomData;

//- (void)agileHubDidUserVote: (NSDictionary *) userVoteData;
//- (void)agileHubDidVoteFinish: (NSDictionary *) voteData;
//- (void)agileHubDidVoteOpen: (NSDictionary *) voteData;
//- (void)agileHubDidVoteClose: (NSDictionary *) voteData;
@end