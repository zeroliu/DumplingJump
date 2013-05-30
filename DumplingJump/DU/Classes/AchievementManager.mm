//
//  AchievementManager.m
//  CastleRider
//
//  Created by zero.liu on 3/18/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "AchievementManager.h"
#import "Constants.h"
#import "UserData.h"
#import "GameModel.h"
#import "GameLayer.h"
#import "Hub.h"
#import "GameUI.h"
#import "TutorialManager.h"

@interface AchievementManager()
@property (nonatomic, retain) NSMutableDictionary *registeredEvent;
@property (nonatomic, retain) NSMutableArray *unlockedEvent;
@end

@implementation AchievementManager
@synthesize
registeredEvent     =   _registeredEvent,
unlockedEvent       =   _unlockedEvent;

+ (id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[AchievementManager alloc] init];
    }
    
    return shared;
}

- (id) init
{
    if (self = [super init])
    {
        _registeredEvent = [[NSMutableDictionary alloc] init];
        _unlockedEvent = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) registerAchievement:(NSDictionary *)achievementData
{
    if (![[TutorialManager shared] isInTutorial])
    {
        NSString *notificationName = [achievementData objectForKey:@"type"];
        [_registeredEvent setObject:achievementData forKey:notificationName];
        if ([notificationName isEqualToString:NOTIFICATION_BOOSTER_UNDER])
        {
            //booster under achievement
            [MESSAGECENTER addObserver:self selector:@selector(getBoosterUnder:) name:notificationName object:nil];
        }
        else if ([notificationName isEqualToString:NOTIFICATION_DIE_TIME])
        {
            [MESSAGECENTER addObserver:self selector:@selector(checkDieTime:) name:notificationName object:nil];
        }
        else
        {
            [MESSAGECENTER addObserver:self selector:@selector(checkRegularAchievement:) name:notificationName object:nil];
        }
    }
}

- (void) removeAllNotification
{
    for (NSString *notificationName in [_registeredEvent allKeys])
    {
        [MESSAGECENTER removeObserver:self name:notificationName object:nil];
    }
    [_registeredEvent removeAllObjects];
}

- (void) removeNotificationByName:(NSString *)name
{
    [MESSAGECENTER removeObserver:self name:name object:nil];
    [_registeredEvent removeObjectForKey:name];
}

- (id) getUnlockedEvents
{
    return self.unlockedEvent;
}

- (void) removeAllUnlockedEvent
{
    [self.unlockedEvent removeAllObjects];
}

- (float) getFinishPercentageWithType:(NSString *)type target:(float)target
{
    float resultPercentage = 0;
    float current = 0;
    if ([type isEqualToString:@"lifeDie"])
    {
        current = [[USERDATA objectForKey:@"die"] floatValue];
        
    }
    else if ([type isEqualToString:@"lifeDistance"])
    {
        current = [[USERDATA objectForKey:@"totalDistance"] floatValue];
    }
    else if ([type isEqualToString:@"lifeStars"])
    {
        current = [[USERDATA objectForKey:@"totalStar"] floatValue];
    }
    else if ([type isEqualToString:@"lifeJump"])
    {
        current = [[USERDATA objectForKey:@"totalJump"] floatValue];
    }
    else if ([type isEqualToString:@"lifeJump"])
    {
        current = [[USERDATA objectForKey:@"totalJump"] floatValue];
    }
    
    resultPercentage = MIN(1, current / target);
    return resultPercentage;
}

#pragma mark -
#pragma mark Notification selector
//Regular achievement means can simply compare the number
- (void) checkRegularAchievement:(NSNotification *)notification
{
    NSString *key = notification.name;
    NSDictionary *achievementData = [_registeredEvent objectForKey:key];
    int updatedNum = [[notification.userInfo objectForKey:@"num"] intValue];
    if (achievementData != nil)
    {
        NSString *restrictType = [achievementData objectForKey:@"restriction"];
        
        if ([self checkRestrinction:restrictType])
        {
            if (updatedNum >= [[achievementData objectForKey:@"number"] intValue])
            {
                [self unlockAchievement:achievementData];
            }
        }
    }
}

- (void) getBoosterUnder:(NSNotification *)notification
{
    NSString *key = notification.name;
    NSDictionary *achievementData = [_registeredEvent objectForKey:key];
    if (achievementData != nil)
    {
        if ([self checkRestrinction:[achievementData objectForKey:@"restriction"]])
        {
            [self unlockAchievement:achievementData];
        }
    }
}

- (void) checkDieTime:(NSNotification *)notification
{
    NSString *key = notification.name;
    NSDictionary *achievementData = [_registeredEvent objectForKey:key];
    if (achievementData != nil)
    {
        if ([self checkRestrinction:[achievementData objectForKey:@"restriction"]])
        {
            float updatedNum = [[notification.userInfo objectForKey:@"num"] floatValue];
            if (achievementData != nil)
            {
                if (updatedNum <= [[achievementData objectForKey:@"number"] floatValue])
                {
                    [self unlockAchievement:achievementData];
                }
            }
        }
    }
}


#pragma mark -
#pragma mark private
- (BOOL) checkRestrinction:(NSString *)restrictType
{
    BOOL restrictionSatisfied = YES;
    
    if (restrictType != nil)
    {
        if ([restrictType isEqualToString:@"star"])
        {
            if (GAMEMODEL.star > 0)
            {
                restrictionSatisfied = NO;
            }
        }
        else if ([restrictType isEqualToString:@"jump"])
        {
            if (GAMEMODEL.jumpCount > 0)
            {
                restrictionSatisfied = NO;
            }
        }
        else if ([restrictType isEqualToString:@"powerup"])
        {
            if (GAMEMODEL.useBoosterCount > 0 ||
                GAMEMODEL.useSpringCount > 0 ||
                GAMEMODEL.useMagicCount > 0)
            {
                restrictionSatisfied = NO;
            }
        }
        else if ([restrictType isEqualToString:@"booster"])
        {
            if (GAMEMODEL.useBoosterCount > 0)
            {
                restrictionSatisfied = NO;
            }
        }
        else if ([restrictType isEqualToString:@"spring"])
        {
            if (GAMEMODEL.useSpringCount > 0)
            {
                restrictionSatisfied = NO;
            }
        }
        else if ([restrictType isEqualToString:@"sword"])
        {
            if (GAMEMODEL.useMagicCount > 0)
            {
                restrictionSatisfied = NO;
            }
        }
        else if ([restrictType isEqualToString:@"item"])
        {
            if (GAMEMODEL.useRebornCount > 0 ||
                GAMEMODEL.useHeadstartCount > 0)
            {
                restrictionSatisfied = NO;
            }
        }
        else if ([restrictType isEqualToString:@"reborn"])
        {
            if (GAMEMODEL.useRebornCount > 0)
            {
                restrictionSatisfied = NO;
            }
        }
        else if ([restrictType isEqualToString:@"headstart"])
        {
            if (GAMEMODEL.useHeadstartCount > 0)
            {
                restrictionSatisfied = NO;
            }
        }
    }
    
    return restrictionSatisfied;
}

- (void) unlockAchievement:(NSDictionary *)achievementData
{
    NSString *groupID = [achievementData objectForKey:@"group"];
    NSString *achievementID = [achievementData objectForKey:@"id"];
    [((UserData *)[UserData shared]).userAchievementDataDictionary setObject:@"YES" forKey:[NSString stringWithFormat:@"%@-%@", groupID, achievementID]];
    [_unlockedEvent addObject:achievementData];
    [self removeNotificationByName:[achievementData objectForKey:@"type"]];
    [[GameUI shared] addAchievementUnlockMessageWithName:[achievementData objectForKey:@"name"]];
}

- (void)dealloc
{
    [self removeAllNotification];
    [_registeredEvent release];
    [_unlockedEvent release];
    [super dealloc];
}
@end
