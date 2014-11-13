//
//  SPPRoom.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPRoom.h"
#import "SPPBaseEntity+Protected.h"

NSString *const SPPRoom_onChanged = @"SPPRoom_onChanged";
NSString *const SPPRoom_onUserLeft = @"SPPRoom_onUserLeft";

@implementation SPPRoom {
    BOOL isPropertiesChanged;
    SPPListItemConstructorBlock _userItemConstructor;
    SPPListItemConstructorBlock _voteItemConstructor;
}

@synthesize name = _name;
@synthesize description = _description;
@synthesize isActive = _isActive;
@synthesize connectedUsers;
@synthesize itemsToVote;

@synthesize roomDelegate;

- (void)dealloc {
    NSLog(@"********** Room '%@' (id=%ld) deallocated.", self.name, (long)self.entityId);
}

+ (instancetype) SPPRoomWithDataDictionary: (NSDictionary*) initData {
    return [SPPRoom SPPBaseEntityWithDataDictionary:initData];
}

- (SPPListItemConstructorBlock) userItemConstructor {
    if (_userItemConstructor == nil) {
        _userItemConstructor = ^(NSObject *owner, NSDictionary *initData) {
            return [SPPUser SPPBaseEntityWithDataDictionary:initData];
        };
    }
    return _userItemConstructor;
}

- (SPPListItemConstructorBlock) voteItemConstructor {
    if (_voteItemConstructor == nil) {
        _voteItemConstructor = ^(NSObject *owner, NSDictionary *initData) {
            SPPVote *vote = [SPPVote SPPBaseEntityWithDataDictionary:initData];
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

- (NSString*) getNotificationName {
    return SPPRoom_onChanged;
}

- (void) didUpdateUser:(NSDictionary*)userDto {
    [self insertUpdateItemInList:connectedUsers useItemData:userDto useItemConstructor:self.userItemConstructor];
}

- (void) didRemoveUser:(NSDictionary*)userDto {
    SPPBaseEntity *deletedUser = [self deleteItemInList:connectedUsers useItemData:userDto];
    if (deletedUser) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SPPRoom_onUserLeft
                                                            object:self
                                                          userInfo:@{@"deletedUser": (SPPUser*)deletedUser}];
    }
}

- (void) didUserVote:(NSDictionary*)userVoteDto {
    NSInteger voteId=[[userVoteDto objectForKey:@"VoteItemId"] integerValue];
    NSInteger idx = [self.itemsToVote indexOfObjectPassingTest:^BOOL(SPPBaseEntity* item, NSUInteger idx, BOOL *stop) {
        return (item.entityId == voteId);
    }];
    if (idx != NSNotFound) {
        SPPVote *vote = self.itemsToVote[idx];
        [vote userDidVoteWithData:userVoteDto];
    }
}

- (void) didUpdateVote: (NSDictionary *) voteDto {
    [self insertUpdateItemInList:itemsToVote useItemData:voteDto useItemConstructor:self.voteItemConstructor];
}
     
#pragma mark - SPPVoteDelegate
- (void)SPPVote:(SPPVote*)vote doVote: (NSInteger) voteValue {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:withVote:doVote:)]) {
        __weak SPPRoom *weakSelf = self;
        [roomDelegate SPPRoom:weakSelf withVote:vote doVote:voteValue];
    }
}

- (void)SPPVoteOpen:(SPPVote*)vote {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:openVote:)]) {
        __weak SPPRoom *weakSelf = self;
        [roomDelegate SPPRoom:weakSelf openVote:vote];
    }
}

- (void)SPPVoteClose:(SPPVote*)vote withOveralValue:(NSInteger)overalValue {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:closeVote:withOveralValue:)]) {
        __weak SPPRoom *weakSelf = self;
        [roomDelegate SPPRoom:weakSelf closeVote:vote withOveralValue:overalValue];
    }
}

#pragma mark - room handling
- (void)removeUser:(SPPUser*)user {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:removeUser:)]) {
        __weak SPPRoom *weakSelf = self;
        [roomDelegate SPPRoom:weakSelf removeUser:user];
    }
}

- (void)removeVote:(SPPVote*)vote {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:removeVote:)]) {
        __weak SPPRoom *weakSelf = self;
        [roomDelegate SPPRoom:weakSelf removeVote:vote];
    }
}

#pragma mark -

- (void)changeState:(BOOL)newState {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:changeState:)]) {
        __weak SPPRoom *weakSelf = self;
        [roomDelegate SPPRoom:weakSelf changeState:newState];
    }
}

@end