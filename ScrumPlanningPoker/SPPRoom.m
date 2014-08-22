//
//  SPPRoom.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPRoom.h"
#import "SPPBaseEntity+Protected.h"
#import "SPPUser.h"
#import "SPPVote.h"

NSString *const SPPRoom_onChanged = @"SPPRoom_onChanged";

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
    NSLog(@"********** Room '%@' (id=%d) deallocated.", self.name, self.entityId);
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

- (NSString*) getNotificationName {
    return SPPRoom_onChanged;
}

- (void) updateUser:(NSDictionary*)userDto {
    [self insertUpdateItemInList:connectedUsers useItemData:userDto useItemConstructor:self.userItemConstructor];
}

- (void) removeUser:(NSDictionary*)userDto {
    [self deleteItemInList:connectedUsers useItemData:userDto];
}

- (void) userVote:(NSDictionary*)userVoteDto {
    NSInteger voteId=[[userVoteDto objectForKey:@"VoteItemId"] integerValue];
    NSInteger idx = [self.itemsToVote indexOfObjectPassingTest:^BOOL(SPPBaseEntity* item, NSUInteger idx, BOOL *stop) {
        return (item.entityId == voteId);
    }];
    if (idx != NSNotFound) {
        SPPVote *vote = self.itemsToVote[idx];
        [vote userDidVoteWithData:userVoteDto];
    }
}

- (void) updateVote: (NSDictionary *) voteDto {
    [self insertUpdateItemInList:itemsToVote useItemData:voteDto useItemConstructor:self.voteItemConstructor];
}
     
#pragma mark + SPPVoteDelegate
- (void)SPPVote:(SPPVote*)vote doVote: (NSInteger) voteValue {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:withVote:doVote:)]) {
        [roomDelegate SPPRoom:self withVote:vote doVote:voteValue];
    }
}

- (void)SPPVoteOpen:(SPPVote*)vote {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:openVote:)]) {
        [roomDelegate SPPRoom:self openVote:vote];
    }
}

- (void)SPPVoteClose:(SPPVote*)vote withOveralValue:(NSInteger)overalValue {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:closeVote:withOveralValue:)]) {
        [roomDelegate SPPRoom:self closeVote:vote withOveralValue:overalValue];
    }
}

#pragma mark - SPPVoteDelegate

- (void)changeState:(BOOL)newState {
    if (roomDelegate && [roomDelegate respondsToSelector:@selector(SPPRoom:changeState:)]) {
        [roomDelegate SPPRoom:self changeState:newState];
    }
}

@end