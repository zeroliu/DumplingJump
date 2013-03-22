//
//  ItemUnlockUI
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUUI.h"
#import "MissionNode.h"

@interface ItemUnlockUI : DUUI
{
    CGSize winsize;
    
    CCLabelTTF *itemTitle;
    CCLabelTTF *multiplierNum;
    CCSprite *unlockedItemSprite;
    CCSprite *lockedItemSprite;
    CCSprite *nextItemSprite;
}
+(id) shared;

@end
