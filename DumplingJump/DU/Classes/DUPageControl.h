//
//  DUPageControl.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-8.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "Common.h"

@interface DUPageControl : CCNode
-(id) initWithPosition:(CGPoint)pos bulletsNum:(int)num normalSpriteFile:(NSString *)normalSprite selectedSpriteFile:(NSString *)selectedSpriteFile;

-(void) moveToIndex:(int)index;
-(void) addMenuToNode:(CCNode *)node;
-(void) addMenuToNode:(CCNode *)node z:(int)priority;
-(void) removeMenuFromParent;
@end
