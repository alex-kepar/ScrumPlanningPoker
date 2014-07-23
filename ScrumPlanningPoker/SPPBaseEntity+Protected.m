//
//  SPPBaseEntity+Protected.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 7/16/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseEntity+Protected.h"

@implementation SPPBaseEntity (Protected)

- (void) doUpdateFromDictionary:(NSDictionary*) data {
    BOOL isPropertyChanged;
    [self doUpdateFromDictionary:data propertyIsChanged:&isPropertyChanged];
}

- (void) doUpdateFromDictionary:(NSDictionary*) data propertyIsChanged: (BOOL *) isChanged {
    
}

@end
