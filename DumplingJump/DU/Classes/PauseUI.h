//
//  PauseUI.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "DUUI.h"
#import "MissionNode.h"
@interface PauseUI : DUUI
{
    MissionNode *missionNode;
}
+(id) shared;
@end
