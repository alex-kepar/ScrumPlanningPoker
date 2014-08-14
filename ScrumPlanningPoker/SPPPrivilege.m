//
//  SPPPrivilege.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPPrivilege.h"
#import "SPPBaseEntity+Protected.h"

NSString *const SPPPrivilege_onChanged = @"SPPPrivilege_onChanged";

@implementation SPPPrivilege {
    BOOL isPropertiesChanged;
}

@synthesize name = _name;
@synthesize description = _description;

- (void) setName:(NSString *)name {
    if (![_name isEqualToString:name]) {
        isPropertiesChanged = YES;
        _name = name;
    }
}

- (NSString*) name {
    return _name;
}

- (void) setDescription:(NSString *)description {
    if (![_description isEqualToString:description]) {
        isPropertiesChanged = YES;
        _description = description;
    }
}

- (NSString*) description {
    return _description;
}

- (void) doUpdateFromDictionary:(NSDictionary*) data propertyIsChanged: (BOOL *) isChanged {
    [super  doUpdateFromDictionary:data propertyIsChanged:isChanged];
    if (self.entityId != [[data objectForKey:@"Id"] integerValue]) return;
    isPropertiesChanged = NO;
    self.name = [data objectForKey:@"Name"];
    self.description = [data objectForKey:@"Description"];
    if (isPropertiesChanged) {
        *isChanged = YES;
    }
}

- (NSString*) getNotificationName {
    return SPPPrivilege_onChanged;
}

/*- (void) onDidChangeWithList: (NSArray *) list {
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPPrivilege_onChanged
                                                        object:self
                                                      userInfo:@{@"list": list}];
}*/

@end