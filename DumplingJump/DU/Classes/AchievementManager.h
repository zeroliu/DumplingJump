//
//  AchievementManager.h
//  CastleRider
//
//  Created by zero.liu on 3/18/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AchievementManager : NSObject
+ (id) shared;
- (void) registerAchievement:(NSDictionary *)achievementData;
- (void) removeAllNotification;
- (id) getUnlockedEvents;
- (void) removeAllUnlockedEvent;
- (float) getFinishPercentageWithType:(NSString *)type target:(float)target;
@end
