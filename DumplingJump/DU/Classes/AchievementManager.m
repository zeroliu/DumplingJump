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
    NSString *notificationName = [achievementData objectForKey:@"type"];
    [_registeredEvent setObject:achievementData forKey:notificationName];
    [MESSAGECENTER addObserver:self selector:@selector(checkRegularAchievement:) name:notificationName object:nil];
}

- (void) removeAllNotification
{
    for (NSString *notificationName in [_registeredEvent allKeys])
    {
        [MESSAGECENTER removeObserver:notificationName];
    }
    [_registeredEvent removeAllObjects];
}

- (void) removeNotificationByName:(NSString *)name
{
    [MESSAGECENTER removeObserver:name];
    [_registeredEvent removeObjectForKey:name];
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
        if ([achievementData objectForKey:@"restriction"] == nil)
        {
            if (updatedNum >= [[achievementData objectForKey:@"number"] intValue])
            {
                [self unlockAchievement:achievementData];
            }
        }
    }
}

#pragma mark -
#pragma mark private
- (void) unlockAchievement:(NSDictionary *)achievementData
{
    NSString *groupID = [achievementData objectForKey:@"group"];
    NSString *achievementID = [achievementData objectForKey:@"id"];
    [((UserData *)[UserData shared]).userAchievementDataDictionary setObject:@"YES" forKey:[NSString stringWithFormat:@"%@-%@", groupID, achievementID]];
    [_unlockedEvent addObject:achievementData];
    [self removeNotificationByName:[achievementData objectForKey:@"type"]];
}

- (void)dealloc
{
    [_registeredEvent release];
    [_unlockedEvent release];
    [super dealloc];
}
@end
