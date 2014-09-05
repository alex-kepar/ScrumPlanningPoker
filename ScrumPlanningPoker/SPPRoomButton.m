//
//  SPPRoomButton.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 9/4/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPRoomButton.h"
#import "SPPAnimationFactory.h"

@interface SPPRoomButton ()

@property (strong, nonatomic) CATransition *animation;
@property (strong, nonatomic) UIImage *openImage;
@property (strong, nonatomic) UIImage *closeImage;

@end

@implementation SPPRoomButton

//@synthesize isActive = _isActive;
@synthesize room = _room;


//- (void)setIsActive:(BOOL)isActive {
//    [self setImage:[self imageForRoomStatus:isActive] forState:UIControlStateNormal];
//    _isActive = isActive;
//}

//- (BOOL)isActive {
//    return _isActive;
//}

- (void)setRoom:(SPPRoom *)room {
    if (_room != room) {
        _room = room;
        [self redrawWithAnimation:NO];
    }
}

- (SPPRoom*)room {
    return _room;
}

- (CATransition*)animation {
    if (!_animation) {
        _animation = [SPPAnimationFactory editAnimation];
    }
    return _animation;
}

- (UIImage*)openImage {
    if (!_openImage) {
        _openImage = [UIImage imageNamed:@"RoomOpened.png"];
    }
    return _openImage;
}

- (UIImage*)closeImage {
    if (!_closeImage) {
        _closeImage = [UIImage imageNamed:@"RoomClosed.png"];
    }
    return _closeImage;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)onClick {
    [self.room changeState:!self.room.isActive];
}

- (void)redrawWithAnimation:(BOOL)isAnimate {
    UIImage *image = self.room.isActive ? self.openImage : self.closeImage;
    if (image != [self imageForState:UIControlStateNormal]) {
        if (isAnimate) {
            [self.layer addAnimation:self.animation forKey:@"kCATransitionFade"];
        }
        [self setImage:image forState:UIControlStateNormal];
    }
}

- (void)notifyRoom_onChanged:(NSNotification*) notification {
    SPPRoom *getRoom = notification.object;
    if (self.room != nil && getRoom != nil && getRoom.entityId == self.room.entityId) {
        [self redrawWithAnimation:YES];
    }
}


@end
