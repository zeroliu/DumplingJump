//
//  AchievementData.m
//  CastleRider
//
//  Created by zero.liu on 3/18/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "AchievementData.h"
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

@end
