//
//  SPPBaseEntity+Protected.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseEntity.h"

@interface SPPBaseEntity (Protected)

- (void) doUpdateFromDictionary:(NSDictionary*) data;
- (void) doUpdateFromDictionary:(NSDictionary*) data propertyIsChanged: (BOOL *) isChanged;

@end
