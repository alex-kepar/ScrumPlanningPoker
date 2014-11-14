//
//  SPPAddViewButton.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 11/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPRoom.h"
#import "SPPUser.h"

@interface SPPAddViewButton : UIButton

@property SPPRoom *room;
@property SPPUser *user;

@end
