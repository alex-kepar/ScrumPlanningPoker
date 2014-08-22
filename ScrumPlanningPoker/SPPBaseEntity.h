//
//  SPPBaseEntity.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>

//FOUNDATION_EXPORT NSString *const SPPEntity_onChanged;

@class SPPBaseEntity;

typedef SPPBaseEntity* (^SPPListItemConstructorBlock)(NSObject *owner, NSDictionary *initData);

@protocol SPPBaseEntityNotification<NSObject>
@required
- (NSString*) getNotificationName;
@end


@interface SPPBaseEntity : NSObject <SPPBaseEntityNotification>

@property (readonly) NSInteger entityId;

+ (instancetype) SPPBaseEntityWithDataDictionary:(NSDictionary*)initData;
- (instancetype) initWithDataDictionary:(NSDictionary*)initData;

- (void) updateFromDictionary:(NSDictionary*)data;

- (NSMutableArray*)initializeListFromData:(NSArray*)listData useItemConstructor:(SPPListItemConstructorBlock)itemConstructor;
- (void)synchronizeList:(NSMutableArray*)list fromListData:(NSArray*)listData useItemConstructor:(SPPListItemConstructorBlock)itemConstructor;
- (SPPBaseEntity*)insertUpdateItemInList:(NSMutableArray*)list useItemData:(NSDictionary*)itemData useItemConstructor:(SPPListItemConstructorBlock)itemConstructor;
- (SPPBaseEntity*)deleteItemInList:(NSMutableArray*)list useItemData:(NSDictionary*)itemData;
@end
