//
//  EquipmentUnlockedCell.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-9.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "cocos2d.h"
#import "CCControlButton.h"
@interface EquipmentUnlockedCell : CCNode
{
    CCControlButton *mainButton;
    CCSprite *itemIcon;
    CCSprite *level1;
    CCSprite *level2;
    CCSprite *level3;
    CCSprite *level4;
    CCLabelTTF *line1;
    CCLabelTTF *line2;
    CCLabelTTF *price;
}

-(void) testClick:(id)sender;
@end
