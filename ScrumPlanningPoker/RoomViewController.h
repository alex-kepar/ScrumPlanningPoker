//
//  RoomViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/14/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseViewController.h"
#import "VoteViewController.h"

@interface RoomViewController : SPPBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, VoteViewControllerDelegate>

@property NSDictionary *roomDto;
@property NSString *promptRoot;

@property (weak, nonatomic) IBOutlet UICollectionView *cvUsers;
@property (weak, nonatomic) IBOutlet UITableView *tvVotes;

@end
