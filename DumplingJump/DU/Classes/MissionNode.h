//
//  MissionNode.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "cocos2d.h"
#import "AchievementNode.h"
@interface MissionNode : CCNode
{
    AchievementNode *mission0;
    AchievementNode *mission1;
    AchievementNode *mission2;
    AchievementNode *mission3;
    
    CCSprite *unlockItemSprite;
    CCSprite *unlockedItemSprite;
    CCSprite *unlockBG;
    CCSprite *unlockedBG;
    CCSprite *transitionAnim;
    
    CCLabelTTF *multiplierIconNum;
    CCLabelTTF *unlockItemName;
    CCLabelTTF *unlockItemDescription;
    CCLabelTTF *starNumLabel;
    CCLabelTTF *multiplierNumLabel;
}

@property (nonatomic, retain) NSArray *missionArray;
@property (nonatomic, retain) CCSprite *TransitionAnim;

- (void) drawWithAchievementDataWithGroupID:(int)groupID;
- (void) drawWithUnknown:(int)groupID;
@end
