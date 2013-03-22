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
    
    CCLabelTTF *unlockItemName;
    CCLabelTTF *unlockItemDescription;
}

@property (nonatomic, retain) NSArray *missionArray;

- (void) drawWithAchievementDataWithGroupID:(int)groupID;
- (void) drawWithUnknown:(int)groupID;
@end
