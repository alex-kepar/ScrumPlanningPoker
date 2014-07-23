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

@synthesize roomDelegate;
@synthesize name = _name;
@synthesize description = _description;
@synthesize isActive = _isActive;
@synthesize connectedUsers;
@synthesize itemsToVote;


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

- (void) addUserUseData:(NSDictionary*)userData {
    [self insertUpdateItemInList:connectedUsers useItemData:userData useItemConstructor:self.userItemConstructor];
}

- (void) removeUserUseData:(NSDictionary*)userData {
    [self deleteItemInList:connectedUsers useItemData:userData];
}

- (void) addVoteUseData:(NSDictionary*)voteData {
    [self insertUpdateItemInList:itemsToVote useItemData:voteData useItemConstructor:self.voteItemConstructor];
}

- (void) hubDidUserVote:(NSDictionary*)userVoteData {
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

- (void) hubDidVoteFinish: (NSDictionary *) voteData {
    SPPVote *vote = (SPPVote *)[self insertUpdateItemInList:itemsToVote useItemData:voteData useItemConstructor:self.voteItemConstructor];
    [self onDidVoteFinish:vote];
}

- (void) hubDidVoteOpen: (NSDictionary *) voteData {
    SPPVote *vote = (SPPVote *)[self insertUpdateItemInList:itemsToVote useItemData:voteData useItemConstructor:self.voteItemConstructor];
    [self onDidVoteOpen:vote];
}

- (void) hubDidVoteClose: (NSDictionary *) voteData {
    SPPVote *vote = (SPPVote *)[self insertUpdateItemInList:itemsToVote useItemData:voteData useItemConstructor:self.voteItemConstructor];
    [self onDidVoteClose:vote];
}

- (void) onDidVote: (SPPVote*) vote withUserVote: (SPPUserVote*) userVote {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(room:DidVote:withUserVote:)]) {
        [roomDelegate room:self DidVote:vote withUserVote:userVote];
    }
}

- (void) onDidVoteFinish: (SPPVote*) vote {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(room:DidVoteFinish:)]) {
        [roomDelegate room:self DidVoteFinish:vote];
    }
}

- (void) onDidVoteOpen: (SPPVote*) vote {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(room:DidVoteOpen:)]) {
        [roomDelegate room:self DidVoteOpen:vote];
    }
}

- (void) onDidVoteClose: (SPPVote*) vote {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(room:DidVoteClose:)]) {
        [roomDelegate room:self DidVoteClose:vote];
    }
}

//- (void) open {
//    if (roomDelegate && [roomDelegate respondsToSelector:@selector(openRoom:)]) {
//        [roomDelegate openRoom:self];
//    }
//}
//
//- (void) close {
//    if (roomDelegate && [roomDelegate respondsToSelector:@selector(closeRoom:)]) {
//        [roomDelegate closeRoom:self];
//    }
//}
//
//- (void) vote: (SPPVote*) vote doVote: (NSInteger) voteValue {
//    if (roomDelegate && [roomDelegate respondsToSelector:@selector(vote:doVote:forRooom:)]) {
//        [roomDelegate vote:vote doVote:voteValue forRooom:self];
//    }
//}

@end
