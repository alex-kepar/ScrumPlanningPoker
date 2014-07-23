//
//  SPPBaseEntity+Protected.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/16/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPBaseEntity.h"

@interface SPPBaseEntity (Protected)

- (void) doUpdateFromDictionary:(NSDictionary*) data;
- (void) doUpdateFromDictionary:(NSDictionary*) data propertyIsChanged: (BOOL *) isChanged;

@end
