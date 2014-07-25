//
//  SPPAgileHubRoomDelegate.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/24/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

@protocol SPPAgileHubRoomDelegate<NSObject>
@optional
- (void)agileHubDidJoinUser: (NSDictionary *) userData;
- (void)agileHubDidLeaveUser: (NSDictionary *) userData;
- (void)agileHubDidChangeRoom: (NSDictionary *) roomData;

- (void)agileHubDidUserVote: (NSDictionary *) userVoteData;
- (void)agileHubDidVoteFinish: (NSDictionary *) voteData;
- (void)agileHubDidVoteOpen: (NSDictionary *) voteData;
- (void)agileHubDidVoteClose: (NSDictionary *) voteData;
@end
