//
//  SPPHTPPHandling.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPProperties.h"

@implementation SPPProperties

@synthesize agileHub;
@synthesize connection;

static SPPProperties *sharedProperties_ = nil;

+(SPPProperties *) sharedProperties
{
    if (sharedProperties_ == nil)
    {
        sharedProperties_ = [[SPPProperties alloc] init];
    }
    return sharedProperties_;
}

-(id)init
{
    self = [super init];
    if (self) {
        connection = [[SPPConnection alloc] init];
        agileHub = [[SPPAgileHub alloc] init];
    }
    return self;
}

@end
