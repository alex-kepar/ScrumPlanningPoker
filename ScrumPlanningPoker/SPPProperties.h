//
//  SPPHTPPHandling.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPPProperties : NSObject

@property NSString *server;
@property NSString *room;


+ (SPPProperties *)sharedProperties;

@end
