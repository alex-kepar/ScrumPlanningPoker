//
//  RoomViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseViewController.h"
#import "SPPRoom.h"

@interface RoomViewController : SPPBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property SPPRoom *room;
@property NSString *promptRoot;

@property (weak, nonatomic) IBOutlet UICollectionView *cvUsers;
@property (weak, nonatomic) IBOutlet UITableView *tvVotes;

@end
