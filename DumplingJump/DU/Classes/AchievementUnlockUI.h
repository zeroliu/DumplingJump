//
//  AchievementUnlockUI
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUUI.h"
#import "MissionNode.h"
#import "CCControlButton.h"

@interface AchievementUnlockUI : DUUI
{
    MissionNode *missionNode;
    CCControlButton *forwardButton;
    CGSize winsize;
    CCSprite *whiteMask;
    CCNode *nodeHolder;
}
+(id) shared;

@end
