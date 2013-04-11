//
//  AchievementNode.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "AchievementNode.h"

@implementation AchievementNode
@synthesize MissionName = missionName, DescriptionText = descriptionText, UnlockIcon = unlockIcon, Bar = bar;

- (void)dealloc
{
    [missionName release];
    [descriptionText release];
    [unlockIcon release];
    [bar release];
    [super dealloc];
}

@end
