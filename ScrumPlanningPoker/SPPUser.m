//
//  SPPUser.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPUser.h"
#import "SPPBaseEntity+Protected.h"
#import "SPPPrivilege.h"

NSString *const SPPUser_onChanged = @"SPPUser_onChanged";

@implementation SPPUser {
    BOOL isPropertiesChanged;
}

@synthesize name = _name;
@synthesize isAdmin = _isAdmin;
@synthesize privileges;

- (void) setName:(NSString *)name {
    if (![_name isEqualToString:name]) {
        isPropertiesChanged = YES;
        _name = name;
    }
}

- (NSString*) name {
    return _name;
}

- (void) setIsAdmin:(BOOL)isAdmin {
    if (_isAdmin != isAdmin) {
        isPropertiesChanged = YES;
        _isAdmin = isAdmin;
    }
}

- (BOOL) isAdmin {
    return _isAdmin;
}

- (void) doUpdateFromDictionary:(NSDictionary*) data propertyIsChanged: (BOOL *) isChanged {
    SPPListItemConstructor privelegeItemConstructor = ^(NSObject *owner, NSDictionary *initData) {
        return [SPPPrivilege SPPBaseEntityWithDataDictionary:initData];
    };

    [super doUpdateFromDictionary:data propertyIsChanged:isChanged];
    if (self.entityId != [[data objectForKey:@"Id"] integerValue]) return;
    isPropertiesChanged = NO;
    self.name = [data objectForKey:@"Name"];
    self.isAdmin = [[data objectForKey:@"IsAdmin"] boolValue];

    if (privileges == nil) {
        privileges = [self initializeListFromData:[data objectForKey:@"Privileges"] useItemConstructor:privelegeItemConstructor];
    } else {
        [self synchronizeList:privileges fromListData:[data objectForKey:@"Privileges"] useItemConstructor:privelegeItemConstructor];
    }
    if (isPropertiesChanged) {
        *isChanged = YES;
    }
}

- (NSString*) getNotificationName {
    return SPPUser_onChanged;
}

/*- (void) onDidChangeWithList: (NSArray *) list {
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPUser_onChanged
                                                        object:self
                                                      userInfo:@{@"list": list}];
}*/

@end
