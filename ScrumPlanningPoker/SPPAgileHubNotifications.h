//
//  SPPAgileHubNotifications.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/5/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

// Events:
FOUNDATION_EXPORT NSString *const SPPAgileHub_onUserLogged;
FOUNDATION_EXPORT NSString *const SPPAgileHub_onConnected;
FOUNDATION_EXPORT NSString *const SPPAgileHub_onErrorCatched;

FOUNDATION_EXPORT NSString *const SPPAgileHub_onRoomChanged;

FOUNDATION_EXPORT NSString *const SPPAgileHubRoom_onOpened;
FOUNDATION_EXPORT NSString *const SPPAgileHubRoom_onUserJoined;
FOUNDATION_EXPORT NSString *const SPPAgileHubRoom_onUserLeft;
FOUNDATION_EXPORT NSString *const SPPAgileHubRoom_onChanged;
FOUNDATION_EXPORT NSString *const SPPAgileHubRoom_onUserVoted;
FOUNDATION_EXPORT NSString *const SPPAgileHubRoom_onVoteFinished;
FOUNDATION_EXPORT NSString *const SPPAgileHubRoom_onVoteOpened;
FOUNDATION_EXPORT NSString *const SPPAgileHubRoom_onVoteClosed;

// Methods:
FOUNDATION_EXPORT NSString *const SPPAgileHub_JoinRoom;
FOUNDATION_EXPORT NSString *const SPPAgileHub_LeaveRoom;
FOUNDATION_EXPORT NSString *const SPPAgileHub_Vote;
