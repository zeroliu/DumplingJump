//
//  AchievementData.h
//  CastleRider
//
//  Created by zero.liu on 3/18/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AchievementData : NSObject

@property (nonatomic, assign) int maxGroup;

+ (id) shared;
- (id) getAchievementDataById:(int)theID group:(int)groupID;
@end
