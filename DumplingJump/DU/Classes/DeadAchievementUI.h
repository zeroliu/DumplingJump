//
//  DeadAchievementUI
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUUI.h"
#import "MissionNode.h"

@interface DeadAchievementUI : DUUI
{
    MissionNode *missionNode;
    CGSize winsize;
}
+(id) shared;

@end
