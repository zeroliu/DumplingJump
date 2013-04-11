//
//  AchievementNode.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "cocos2d.h"

@interface AchievementNode : CCNode
{
    CCLabelTTF *missionName;
    CCLabelTTF *descriptionText;
    CCSprite *unlockIcon;
    CCSprite *bar;
}
@property (nonatomic, retain) CCLabelTTF *MissionName;
@property (nonatomic, retain) CCLabelTTF *DescriptionText;
@property (nonatomic, retain) CCSprite *UnlockIcon;
@property (nonatomic, retain) CCSprite *Bar;
@end
