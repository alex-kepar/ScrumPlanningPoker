//
//  SPPRoomViewCell.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPRoomViewCell.h"

@implementation SPPRoomViewCell {
    SPPRoom *room;
}

@synthesize changeStateAction;

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyRoom_onChanged:)
                                                     name:SPPRoom_onChanged
                                                   object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIImage *) imageForRoomStatus: (BOOL)isActive
{
    if(isActive)
    {
        return [UIImage imageNamed:@"RoomOpened.png"];
    }
    else
    {
        return [UIImage imageNamed:@"RoomClosed.png"];
    }
}

- (void) redrawCell {
    _nameLabel.text = room.name;;
    _descriptionLabel.text = room.description;
    _usersCount.text = [NSString stringWithFormat:@"%d", room.connectedUsers.count];
    [_bState setImage:[self imageForRoomStatus:room.isActive] forState:UIControlStateNormal];
}

-(void) initializeWithRoom:(SPPRoom*) initRoom {
    room = initRoom;
    [self redrawCell];
}

-(void) notifyRoom_onChanged:(NSNotification*) notification {
    SPPRoom *getRoom = notification.object;
    if (room != nil && getRoom != nil && getRoom.entityId == room.entityId) {
        [self redrawCell];
    }
}

- (IBAction)actChangeState:(UIButton *)sender {
    if (changeStateAction) {
        changeStateAction(room);
    }
}
@end
