//
//  SPPBaseEntity.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/15/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseEntity.h"
#import "SPPBaseEntity+Protected.h"

@implementation SPPBaseEntity {
}

@synthesize delegate;
@synthesize entityId = _entityId;


+ (instancetype)SPPBaseEntityWithDataDictionary: (NSDictionary*) initData
{
    return [[self alloc] initWithDataDictionary:initData];
}

- (instancetype)initWithDataDictionary:(NSDictionary *)initData
{
    self = [super init];
    if (self)
    {
        _entityId = [[initData objectForKey:@"Id"] integerValue];
        [self doUpdateFromDictionary:initData];
    }
    return self;
}

- (void) updateFromDictionary:(NSDictionary*) data {
    BOOL isPropertiesChanged = NO;
    [self doUpdateFromDictionary:data propertyIsChanged:&isPropertiesChanged];
    if (isPropertiesChanged) {
        if (delegate && [delegate respondsToSelector:@selector(entityDidChange:)]) {
            [delegate entityDidChange:self];
        }
    }
}


#pragma mark + list handling

- (void) _onDidChangeList: (NSMutableArray *) list {
    if (delegate && [delegate respondsToSelector:@selector(entityDidChange:list:)]) {
        [delegate entityDidChange:self list:list];
    }
}

- (BOOL) _changeList: (NSMutableArray*) list fromItemData:(NSDictionary*) itemData useItemConstructor:(SPPListItemConstructor) itemConstructor {
    SPPBaseEntity *itemWasChanged;
    return [self _changeList:list fromItemData:itemData useItemConstructor:itemConstructor itemWasChanged:&itemWasChanged];
}

- (BOOL) _changeList: (NSMutableArray*) list fromItemData:(NSDictionary*) itemData useItemConstructor:(SPPListItemConstructor) itemConstructor itemWasChanged:(SPPBaseEntity**) itemWasChanged {
    BOOL isListChanged = NO;
    *itemWasChanged = nil;
    NSInteger itemId = [[itemData objectForKey:@"Id"] integerValue];
    NSInteger idx = [list indexOfObjectPassingTest:^BOOL(SPPBaseEntity* item, NSUInteger idx, BOOL *stop) {
        return (item.entityId == itemId);
    }];
    if (idx == NSNotFound) {
        *itemWasChanged = itemConstructor(self, itemData);
        [list addObject:*itemWasChanged];
        isListChanged = YES;
    } else {
        *itemWasChanged = [list objectAtIndex:idx];
        [*itemWasChanged updateFromDictionary:itemData];
    }
    return isListChanged;
}

- (void) _sortList: (NSMutableArray*) list {
    [list sortUsingComparator:^NSComparisonResult(SPPBaseEntity *entity1, SPPBaseEntity *entity2) {
        if (entity1.entityId > entity2.entityId) {
            return NSOrderedDescending;
        } else if (entity1.entityId < entity2.entityId) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (NSMutableArray*) initializeListFromData:(NSArray*) listData useItemConstructor:(SPPListItemConstructor) itemConstructor {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:listData.count];
    for (int i = 0; i<listData.count; i++) {
        list[i]=itemConstructor(self, listData[i]);
        //[itemClass SPPBaseEntityWithDataDictionary:listData[i]];
    }
    [self _sortList:list];
    return list;
}

- (void) synchronizeList:(NSMutableArray*) list fromListData:(NSArray*) listData useItemConstructor:(SPPListItemConstructor) itemConstructor {
    if (list == nil) {
        return ;
    }
    BOOL isListChanged = NO;
    NSMutableSet *itemIdList = [NSMutableSet setWithCapacity:listData.count];
    // add and modify items
    for (NSDictionary *itemData in listData) {
        NSInteger itemId = [[itemData objectForKey:@"Id"] integerValue];
        [itemIdList  addObject:[NSNumber numberWithInteger:itemId]];
        if ([self _changeList:list fromItemData:itemData useItemConstructor:itemConstructor]) {
            isListChanged = YES;
        }
    }
    // delete items
    for (int i = (list.count - 1); i>=0; i--) {
        NSNumber *entityId = [NSNumber numberWithInteger:((SPPBaseEntity*)list[i]).entityId];
        if ([itemIdList member:entityId] == nil) {
            [list removeObjectAtIndex:i];
            isListChanged = YES;
        }
    }
    if (isListChanged) {
        [self _sortList:list];
        [self _onDidChangeList:list];
    }
}

- (SPPBaseEntity*) insertUpdateItemInList:(NSMutableArray*) list useItemData:(NSDictionary*) itemData useItemConstructor:(SPPListItemConstructor) itemConstructor {
    if (list == nil) {
        return nil;
    }
    SPPBaseEntity *itemWasChanged;
    if ([self _changeList:list fromItemData:itemData useItemConstructor:itemConstructor itemWasChanged:&itemWasChanged]) {
        [self _sortList:list];
        [self _onDidChangeList:list];
    }
    return itemWasChanged;
}

- (SPPBaseEntity*) deleteItemInList:(NSMutableArray*) list useItemData:(NSDictionary*) itemData{
    if (list == nil) {
        return nil;
    }
    NSInteger itemId = [[itemData objectForKey:@"Id"] integerValue];
    NSInteger idx = [list indexOfObjectPassingTest:^BOOL(SPPBaseEntity* item, NSUInteger idx, BOOL *stop) {
        return (item.entityId == itemId);
    }];
    SPPBaseEntity *itemWasChanged = nil;
    if (idx != NSNotFound) {
        itemWasChanged = list[idx];
        [list removeObjectAtIndex:idx];
        [self _sortList:list];
        [self _onDidChangeList:list];
    }
    return itemWasChanged;
}

#pragma mark - list handling

@end
