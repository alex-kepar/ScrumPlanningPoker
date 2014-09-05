//
//  SPPRoomViewCell.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPRoom.h"
#import "SPPRoomButton.h"

typedef void(^SPPRoomViewCellRoomAction)(SPPRoom *room);

@interface SPPRoomViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet SPPRoomButton *outRoomButton;
@property (weak, nonatomic) IBOutlet UILabel *usersCount;
//@property (nonatomic, copy) SPPRoomViewCellRoomAction changeStateAction;

-(void) initializeWithRoom:(SPPRoom*) initRoom;

@end
