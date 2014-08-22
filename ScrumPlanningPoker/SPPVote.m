//
//  SPPVote.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPVote.h"
#import "SPPBaseEntity+Protected.h"

NSString *const SPPVote_onChanged = @"SPPVote_onChanged";

@implementation SPPVote {
    BOOL isPropertiesChanged;
    SPPListItemConstructorBlock _voteUserItemConstructor;
}

//@synthesize voteDelegate;

@synthesize content = _content;
@synthesize roomId = _roomId;
@synthesize isClosed = _isClosed;
@synthesize isOpened = _isOpened;
@synthesize isFinished = _isFinished;
@synthesize overallMark = _overallMark;
@synthesize votedUsers;

@synthesize voteDelegate;

- (void)dealloc {
    NSLog(@"********** Vote '%@' deallocated.", self.content);
}

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

- (SPPListItemConstructorBlock) voteUserItemConstructor {
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
    self.content = [data valueForKey:@"Content"];
    if ([[data allKeys] containsObject:@"RoomId"]) {
        self.roomId = [[data valueForKey:@"RoomId"] integerValue];
    } else {
        self.roomId = [[data valueForKey:@"HostRoomId"] integerValue];
    }
    self.isClosed = [[data valueForKey:@"Closed"] boolValue];
    self.isOpened = [[data valueForKey:@"Opened"] boolValue];
    self.isFinished = [[data valueForKey:@"Finished"] boolValue];
    self.overallMark = [[data valueForKey:@"OverallMark"] integerValue];
    if (votedUsers == nil) {
        votedUsers = [self initializeListFromData:[data valueForKey:@"VotedUsers"] useItemConstructor:self.voteUserItemConstructor];
    } else {
        [self synchronizeList:votedUsers fromListData:[data valueForKey:@"VotedUsers"] useItemConstructor:self.voteUserItemConstructor];
    }
    if (isPropertiesChanged) {
        *isChanged = YES;
    }
}

- (NSString*) getNotificationName {
    return SPPVote_onChanged;
}

- (SPPUserVote*) userDidVoteWithData:(NSDictionary*)userVoteData {
    return (SPPUserVote*)[self insertUpdateItemInList:votedUsers useItemData:userVoteData useItemConstructor:self.voteUserItemConstructor];
}

- (void) doVote: (NSInteger) voteValue {
    if (voteDelegate && [voteDelegate respondsToSelector:@selector(SPPVote:doVote:)]) {
        [voteDelegate SPPVote:self doVote:voteValue];
    }
}

- (void)open {
    if (voteDelegate && [voteDelegate respondsToSelector:@selector(SPPVoteOpen:)]) {
        [voteDelegate SPPVoteOpen:self];
    }
}

- (void)closeWithOveralValue:(NSInteger)overalValue {
    if (voteDelegate && [voteDelegate respondsToSelector:@selector(SPPVoteClose:withOveralValue:)]) {
        [voteDelegate SPPVoteClose:self withOveralValue:overalValue];
    }
}

@end
