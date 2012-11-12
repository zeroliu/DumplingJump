//
//  CircleMask.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "cocos2d.h"

@interface CircleMask : CCNode

-(id) initWithTexture:(CCSprite *)textureSprite Mask:(CCSprite *)maskSprite;
-(CCSprite *)maskedSpriteWithSprite:(CGPoint)pos;
-(void)updateSprite:(CGPoint)pos;
-(void)removeMask;
@end
