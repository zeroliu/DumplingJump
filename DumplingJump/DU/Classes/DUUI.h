//
//  DUUI.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "Common.h"
#import "CCBAnimationManager.h"
#import "CCControlButton.h"
@interface DUUI : CCNode
{
    NSString *ccbFileName;
    int priority;
    CCBAnimationManager *animationManager;
    CCNode *node;
}

-(void) createUI;
-(void) createUIwithParent:(CCNode *)parent;
-(void) destroy;
@end
