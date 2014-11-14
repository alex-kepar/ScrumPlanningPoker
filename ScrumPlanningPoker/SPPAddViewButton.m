//
//  SPPAddViewButton.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 11/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPAddViewButton.h"

@implementation SPPAddViewButton


@synthesize room = _room;
@synthesize user = _user;


- (void)setRoom:(SPPRoom *)room {
    if (_room != room) {
        _room = room;
        [self redrawWithAnimation:NO];
    }
}

- (SPPRoom*)room {
    return _room;
}

- (void)setUser:(SPPUser *)user {
    if (_user != user) {
        _user = user;
        [self redrawWithAnimation:NO];
    }
}

- (SPPUser*)user{
    return _user;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyRoom_onChanged:)
                                                     name:SPPRoom_onChanged
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)redrawWithAnimation:(BOOL)isAnimate {
    self.enabled = _room ? _room.isActive : NO &&
                   _user ? _user.isAdmin : NO;
}

- (void)notifyRoom_onChanged:(NSNotification*) notification {
    SPPRoom *getRoom = notification.object;
    if (self.room != nil && getRoom != nil && getRoom.entityId == self.room.entityId) {
        [self redrawWithAnimation:YES];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
