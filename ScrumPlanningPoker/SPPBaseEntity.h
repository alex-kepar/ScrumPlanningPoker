//
//  SPPBaseEntity.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/15/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SPPBaseEntity;
@protocol SPPBaseEntityDelegate<NSObject>
//@required
@optional
- (void)entityDidChange: (SPPBaseEntity *) entity;
- (void)entityDidChange: (SPPBaseEntity *) entity list: (NSMutableArray *) list;
@end

typedef SPPBaseEntity* (^SPPListItemConstructor)(NSObject *owner, NSDictionary *initData);

@interface SPPBaseEntity : NSObject

@property (nonatomic, assign)id <SPPBaseEntityDelegate> delegate;
@property (readonly) NSInteger entityId;

+ (instancetype) SPPBaseEntityWithDataDictionary: (NSDictionary*) initData;
- (instancetype) initWithDataDictionary:(NSDictionary *) initData;

- (void) updateFromDictionary:(NSDictionary*) data;


- (NSMutableArray*) initializeListFromData:(NSArray*) listData useItemConstructor:(SPPListItemConstructor) itemConstructor;
- (void) synchronizeList:(NSMutableArray*) list fromListData:(NSArray*) listData useItemConstructor:(SPPListItemConstructor) itemConstructor;
- (SPPBaseEntity*) insertUpdateItemInList:(NSMutableArray*) list useItemData:(NSDictionary*) itemData useItemConstructor:(SPPListItemConstructor) itemConstructor;
- (SPPBaseEntity*) deleteItemInList:(NSMutableArray*) list useItemData:(NSDictionary*) itemData;
@end
