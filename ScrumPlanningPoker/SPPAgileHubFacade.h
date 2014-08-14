//
//  SPPAgileHubFacade.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/11/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPAgileHub.h"
#import "SPPRoom.h"

@class SPPAgileHubFacade;

FOUNDATION_EXPORT NSString *const SPPAgileHubFacade_onChanged;
FOUNDATION_EXPORT NSString *const SPPAgileHubFacade_onDidOpenRoom;

//@protocol SPPAgileHubFacadeDelegate<NSObject>
//@optional
//- (void) SPPAgileHubFacade:(SPPAgileHubFacade*)agileHubFacade DidOpenRoom:(SPPRoom*)room;
//@end

@interface SPPAgileHubFacade : NSObject <SPPRoomDelegate>

//@property (nonatomic, assign)id <SPPAgileHubFacadeDelegate> delegate;

@property (readonly) NSArray *rooms;
@property (readonly) SPPRoom *openedRoom;

+ (instancetype) SPPAgileHubFacadeWithAgileHub:(SPPAgileHub*)initAgileHub roomList:(NSArray*)initRoomList;
- (instancetype) initWithAgileHub:(SPPAgileHub*)initAgileHub roomList:(NSArray*)initRoomList;

- (void) openRoomUseIndex:(NSInteger)roomIndex;
- (void) openRoomUseName:(NSString*)roomName;
- (void) closeRoom;

@end
