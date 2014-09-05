//
//  SPPAnimationFactory.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 9/5/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPAnimationFactory.h"

@implementation SPPAnimationFactory

+ (CATransition*)editAnimation {
    CATransition *ret = [CATransition animation];
    ret.duration = 1.0;
    ret.type = kCATransitionPush;
    ret.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return ret;
}

@end
