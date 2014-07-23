//
//  SPPVote.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPVote.h"
#import "SPPBaseEntity+Protected.h"

@implementation SPPVote {
    BOOL isPropertiesChanged;
    SPPListItemConstructor _voteUserItemConstructor;
}

//@synthesize voteDelegate;

@synthesize content = _content;
@synthesize roomId = _roomId;
@synthesize isClosed = _isClosed;
@synthesize isOpened = _isOpened;
@synthesize isFinished = _isFinished;
@synthesize overallMark = _overallMark;
@synthesize votedUsers;

- (void) setContent:(NSString *)content {
    if (![_content isEqualToString:content]) {
        isPropertiesChanged = YES;
        _content = content;
    }
}

- (NSString*) content {
    return _content;
}

- (void) setRoomId:(NSInteger)roomId {
    if (_roomId != roomId) {
        isPropertiesChanged = YES;
        _roomId = roomId;
    }
}

- (NSInteger) roomId {
    return _roomId;
}

- (void) setIsClosed:(BOOL)isClosed {
    if (_isClosed != isClosed) {
        isPropertiesChanged = YES;
        _isClosed = isClosed;
    }
}

- (BOOL) isClosed {
    return _isClosed;
}

- (void) setIsOpened:(BOOL)isOpened {
    if (_isOpened != isOpened) {
        isPropertiesChanged = YES;
        _isOpened = isOpened;
    }
}

- (BOOL) isOpened {
    return _isOpened;
}

- (void) setIsFinished:(BOOL)isFinished {
    if (_isFinished != isFinished) {
        isPropertiesChanged = YES;
        _isFinished = isFinished;
    }
}

- (BOOL) isFinished {
    return _isFinished;
}

- (void) setOverallMark:(NSInteger)overallMark {
    if (_overallMark != overallMark) {
        isPropertiesChanged = YES;
        _overallMark = overallMark;
    }
}

- (NSInteger) overallMark {
    return _overallMark;
}


- (SPPListItemConstructor) voteUserItemConstructor {
    if (_voteUserItemConstructor == nil) {
        _voteUserItemConstructor = ^(NSObject *owner, NSDictionary *initData) {
            SPPUserVote *voteUser = [SPPUserVote SPPBaseEntityWithDataDictionary:initData];
            voteUser.owner = owner;
            return voteUser;
        };
    }
    return _voteUserItemConstructor;
}


- (void) doUpdateFromDictionary:(NSDictionary*) data propertyIsChanged: (BOOL *) isChanged {
    if (self.entityId != [[data objectForKey:@"Id"] integerValue]) return;
    [super doUpdateFromDictionary:data propertyIsChanged: isChanged];
    isPropertiesChanged = NO;
    self.content = [data objectForKey:@"Content"];
    self.roomId = [[data objectForKey:@"RoomId"] integerValue];
    self.isClosed = [[data objectForKey:@"Closed"] boolValue];
    self.isOpened = [[data objectForKey:@"Opened"] boolValue];
    self.isFinished = [[data objectForKey:@"Finished"] boolValue];
    self.overallMark = [[data objectForKey:@"OverallMark"] integerValue];
    if (votedUsers == nil) {
        votedUsers = [self initializeListFromData:[data objectForKey:@"VotedUsers"] useItemConstructor:self.voteUserItemConstructor];
    } else {
        [self synchronizeList:votedUsers fromListData:[data objectForKey:@"VotedUsers"] useItemConstructor:self.voteUserItemConstructor];
    }
    if (isPropertiesChanged) {
        *isChanged = YES;
    }
}

- (SPPUserVote*) userDidVoteWithData:(NSDictionary*)userVoteData {
    return (SPPUserVote*)[self insertUpdateItemInList:votedUsers useItemData:userVoteData useItemConstructor:self.voteUserItemConstructor];
}

@end
