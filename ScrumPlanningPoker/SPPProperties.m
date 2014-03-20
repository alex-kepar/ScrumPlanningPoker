//
//  SPPHTPPHandling.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/13/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPProperties.h"

@implementation SPPProperties
//{
    //SURLSession *session = [NSURLSession sharedSession];
//}

@synthesize server;
@synthesize selectedRoom;
@synthesize userToken;
@synthesize user;
@synthesize room;
@synthesize hubConnection;
@synthesize agileHub;

static SPPProperties *sharedProperties_ = nil;

+(SPPProperties *) sharedProperties
{
    if (sharedProperties_ == nil)
    {
        sharedProperties_ = [[SPPProperties alloc] init];
    }
    return sharedProperties_;
}

@end
