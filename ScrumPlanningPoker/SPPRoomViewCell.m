//
//  SPPRoomViewCell.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPRoomViewCell.h"
#import "SPPAgileHubNotifications.h"

@implementation SPPRoomViewCell {
    NSInteger roomId;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyAgileHub_RoomChanged:) name:SPPAgileHub_onRoomChanged object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(UIImage *) imageForRoomStatus: (BOOL)isOpened
{
    if(isOpened)
    {
        return [UIImage imageNamed:@"RoomOpened.png"];
    }
    else
    {
        return [UIImage imageNamed:@"RoomClosed.png"];
    }
}

- (void) redrawRoomDto: (NSDictionary*) roomDto {
    _nameLabel.text = [roomDto valueForKey:@"Name"];
    _descriptionLabel.text = [roomDto valueForKey:@"Description"];
    _statusImage.image = [self imageForRoomStatus: [[roomDto valueForKey:@"Active"] boolValue]];
    _usersCount.text = [NSString stringWithFormat:@"%d", [[roomDto valueForKey:@"ConnectedUsers"] count]];
}

-(void) initializeWithRoomDto:(NSDictionary*) initRoomDto {
    roomId = [[initRoomDto valueForKey:@"Id"] integerValue];
    [self redrawRoomDto:initRoomDto];
}

-(void) notifyAgileHub_RoomChanged:(NSNotification*) notification {
    NSDictionary *roomDto = notification.userInfo[@"roomDto"];
    if (roomId == [[roomDto valueForKey:@"Id"] integerValue]) {
        [self redrawRoomDto:roomDto];
    }
}

@end
