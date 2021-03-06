//
//  SPPRoomViewCell.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/19/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPPRoomViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *usersCount;
@end
