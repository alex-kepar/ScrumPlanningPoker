//
//  SPPVoteUser.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 8/8/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPUserVote.h"
#import "SPPBaseEntity+Protected.h"

NSString *const SPPUserVote_onChanged = @"SPPUserVote_onChanged";

@implementation SPPUserVote {
    BOOL isPropertiesChanged;
}

@synthesize mark = _mark;
@synthesize userId = _userId;

- (void) setMark:(NSInteger)mark {
    if (_mark != mark) {
        isPropertiesChanged = YES;
        _mark = mark;
    }
}

- (NSInteger) mark {
    return _mark;
}

- (void) setUserId:(NSInteger)userId {
    if (_userId != userId) {
        isPropertiesChanged = YES;
        _userId = userId;
    }
}

- (NSInteger) userId {
    return _userId;
}

- (void) doUpdateFromDictionary:(NSDictionary*) data propertyIsChanged: (BOOL *) isChanged {
    [super doUpdateFromDictionary:data propertyIsChanged:isChanged];
    if (self.entityId != [[data objectForKey:@"Id"] integerValue]) return;
    isPropertiesChanged = NO;
    self.mark = [[data objectForKey:@"Mark"] integerValue];
    self.userId = [[data objectForKey:@"UserId"] integerValue];
    if (isPropertiesChanged) {
        *isChanged = YES;
    }
}

- (NSString*) getNotificationName {
    return SPPUserVote_onChanged;
}

/*
- (void) onDidChangeWithList: (NSArray *) list {
    [[NSNotificationCenter defaultCenter] postNotificationName:SPPUserVote_onChanged
                                                        object:self
                                                      userInfo:@{@"list": list}];
}
*/
@end
