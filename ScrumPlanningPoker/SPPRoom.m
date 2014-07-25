//
//  SPPRoom.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPRoom.h"
#import "SPPBaseEntity+Protected.h"
#import "SPPUser.h"
#import "SPPVote.h"

@implementation SPPRoom {
    BOOL isPropertiesChanged;
    SPPListItemConstructor _userItemConstructor;
    SPPListItemConstructor _voteItemConstructor;
}

@synthesize name = _name;
@synthesize description = _description;
@synthesize isActive = _isActive;
@synthesize connectedUsers;
@synthesize itemsToVote;

@synthesize roomDelegate;

- (SPPListItemConstructor) userItemConstructor {
    if (_userItemConstructor == nil) {
        _userItemConstructor = ^(NSObject *owner, NSDictionary *initData) {
            return [SPPUser SPPBaseEntityWithDataDictionary:initData];
        };
    }
    return _userItemConstructor;
}

- (SPPListItemConstructor) voteItemConstructor {
    if (_voteItemConstructor == nil) {
        _voteItemConstructor = ^(NSObject *owner, NSDictionary *initData) {
            SPPVote *vote = [SPPVote SPPBaseEntityWithDataDictionary:initData];
            vote.owner = owner;
            vote.voteDelegate = (id)owner;
            return vote;
        };
    }
    return _voteItemConstructor;
}

- (void) setName:(NSString*) name {
    if (![_name isEqualToString:name]) {
        isPropertiesChanged = YES;
        _name = name;
    }
}

- (NSString*) name {
    return _name;
}

- (void) setDescription:(NSString *) description {
    if (![_description isEqualToString:description]) {
        isPropertiesChanged = YES;
        _description = description;
    }
}

- (NSString*) description {
    return _description;
}

- (void) setIsActive:(BOOL) isActive {
    if (_isActive != isActive) {
        isPropertiesChanged = YES;
        _isActive = isActive;
    }
}

- (BOOL) isActive {
    return _isActive;
}

- (void) doUpdateFromDictionary:(NSDictionary*) data propertyIsChanged: (BOOL *) isChanged {
    [super doUpdateFromDictionary:data propertyIsChanged:isChanged];
    if (self.entityId != [[data objectForKey:@"Id"] integerValue]) return;
    isPropertiesChanged = NO;
    self.name = [data objectForKey:@"Name"];
    self.description = [data objectForKey:@"Description"];
    self.isActive = [[data objectForKey:@"Active"] boolValue];
    
    if (connectedUsers == nil) {
        connectedUsers = [self initializeListFromData:[data objectForKey:@"ConnectedUsers"] useItemConstructor: self.userItemConstructor];
    } else {
        [self synchronizeList:connectedUsers fromListData:[data objectForKey:@"ConnectedUsers"] useItemConstructor:self.userItemConstructor];
    }
    
    if (itemsToVote == nil) {
        itemsToVote = [self initializeListFromData:[data objectForKey:@"ItemsToVote"] useItemConstructor:self.voteItemConstructor];
    } else {
        [self synchronizeList:itemsToVote fromListData:[data objectForKey:@"ItemsToVote"] useItemConstructor:self.voteItemConstructor];
    }
    if (isPropertiesChanged) {
        *isChanged = YES;
    }
}

- (void) agileHubDidJoinUser:(NSDictionary*)userData {
    [self insertUpdateItemInList:connectedUsers useItemData:userData useItemConstructor:self.userItemConstructor];
}

- (void) agileHubDidLeaveUser:(NSDictionary*)userData {
    [self deleteItemInList:connectedUsers useItemData:userData];
}

- (void)agileHubDidChangeRoom: (NSDictionary *) roomData {
    [self updateFromDictionary:roomData];
}

//- (void) addVoteUseData:(NSDictionary*)voteData {
//    [self insertUpdateItemInList:itemsToVote useItemData:voteData useItemConstructor:self.voteItemConstructor];
//}

- (void) agileHubDidUserVote:(NSDictionary*)userVoteData {
    NSInteger voteId=[[userVoteData objectForKey:@"VoteItemId"] integerValue];
    NSInteger idx = [self.itemsToVote indexOfObjectPassingTest:^BOOL(SPPBaseEntity* item, NSUInteger idx, BOOL *stop) {
        return (item.entityId == voteId);
    }];
    if (idx != NSNotFound) {
        SPPVote *vote = self.itemsToVote[idx];
        SPPUserVote *userVote = [vote userDidVoteWithData:userVoteData];
        [self onDidVote:vote withUserVote:userVote];
    }
}

- (void) agileHubDidVoteFinish: (NSDictionary *) voteData {
    SPPVote *vote = (SPPVote *)[self insertUpdateItemInList:itemsToVote useItemData:voteData useItemConstructor:self.voteItemConstructor];
    [self onDidVoteFinish:vote];
}

- (void) agileHubDidVoteOpen: (NSDictionary *) voteData {
    SPPVote *vote = (SPPVote *)[self insertUpdateItemInList:itemsToVote useItemData:voteData useItemConstructor:self.voteItemConstructor];
    [self onDidVoteOpen:vote];
}

- (void) agileHubDidVoteClose: (NSDictionary *) voteData {
    SPPVote *vote = (SPPVote *)[self insertUpdateItemInList:itemsToVote useItemData:voteData useItemConstructor:self.voteItemConstructor];
    [self onDidVoteClose:vote];
}

- (void) onDidVote: (SPPVote*) vote withUserVote: (SPPUserVote*) userVote {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SPPRoomDidVoteNotification" object:self userInfo:@{@"vote": vote, @"userVote": userVote}];
}

- (void) onDidVoteFinish: (SPPVote*) vote {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SPPRoomDidVoteFinishNotification" object:self userInfo:@{@"vote": vote}];
}

- (void) onDidVoteOpen: (SPPVote*) vote {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SPPRoomDidVoteOpenNotification" object:self userInfo:@{@"vote": vote}];
}

- (void) onDidVoteClose: (SPPVote*) vote {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SPPRoomDidVoteCloseNotification" object:self userInfo:@{@"vote": vote}];
}


#pragma mark + SPPVoteDelegate
- (void)SPPVote:(SPPVote*) vote doVote: (NSInteger) voteValue {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:withVote:doVote:)]) {
            [roomDelegate SPPRoom:self withVote:vote doVote:voteValue];
    }
}
#pragma mark - SPPVoteDelegate


@end
