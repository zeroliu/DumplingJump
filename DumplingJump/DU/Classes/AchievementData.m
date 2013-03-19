//
//  AchievementData.m
//  CastleRider
//
//  Created by zero.liu on 3/18/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "AchievementData.h"
#import "UserData.h"
#import "XMLHelper.h"

@interface AchievementData()
@property (nonatomic, retain) NSDictionary *achievementDictionary;
@end

@implementation AchievementData

@synthesize achievementDictionary = _achievementDictionary;
@synthesize maxGroup = _maxGroup;

+ (id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[AchievementData alloc] init];
    }
    
    return shared;
}

- (id) init
{
    if (self = [super init])
    {
        self.achievementDictionary = [[XMLHelper shared] loadAchievementData];
    }
    
    return self;
}

- (id) getAchievementDataById:(int)theID group:(int)groupID
{
    NSString *combinedID = [NSString stringWithFormat:@"%d-%d", groupID, theID];
    return [self.achievementDictionary objectForKey:combinedID];
}

- (NSArray *) getAvailableAchievementsByGroupID:(int)groupID
{
    NSMutableArray *availableAchievements = [NSMutableArray array];
    for (int i=1; i<=4; i++)
    {
        NSString *key = [NSString stringWithFormat:@"%d-%d", groupID, i];
        if ([[((UserData *)[UserData shared]).userAchievementDataDictionary objectForKey:key] isEqualToString:@"NO"])
        {
            [availableAchievements addObject:[self.achievementDictionary objectForKey:key]];
        }
    }
    return availableAchievements;
}

@end
