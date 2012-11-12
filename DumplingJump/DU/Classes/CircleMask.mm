//
//  CircleMask.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "CircleMask.h"
@interface CircleMask()
{
    CCRenderTexture *rt;
    CCSprite *_maskSprite;
    CCSprite *_textureSprite;
    CCSprite *_retval;
    BOOL isActive;
}

@end

@implementation CircleMask

-(id) initWithTexture:(CCSprite *)textureSprite Mask:(CCSprite *)maskSprite
{
    if (self = [super init])
    {
        _textureSprite = textureSprite;
        _maskSprite = maskSprite;
        isActive = false;
    }
    
    return self;
}

- (CCSprite *)maskedSpriteWithSprite:(CGPoint)pos
{
    // 1
    rt = [[CCRenderTexture renderTextureWithWidth:_textureSprite.contentSize.width height:_textureSprite.contentSize.height] retain];
    
    // 2
    
    //_maskSprite.position = ccp(_maskSprite.contentSize.width/2, _maskSprite.contentSize.height/2);
    _textureSprite.position = ccp(_textureSprite.contentSize.width/2, _textureSprite.contentSize.height/2);
    
    // 3
    [_maskSprite setBlendFunc:(ccBlendFunc){GL_ZERO, GL_ONE_MINUS_SRC_ALPHA}];
    [_textureSprite setBlendFunc:(ccBlendFunc){GL_ONE, GL_ZERO}];
    
    // 4
    [rt begin];
    [_textureSprite visit];
    [_maskSprite visit];
    [rt end];
    
    // 5
    _retval = [CCSprite spriteWithTexture:rt.sprite.texture];
    _retval.flipY = YES;
    
    isActive = true;
    return _retval;
}

-(void)updateSprite:(CGPoint)pos
{
    if (isActive)
    {
        _maskSprite.position = pos;
        [rt begin];
        [_textureSprite visit];
        [_maskSprite visit];
        [rt end];
    }
}

-(void)removeMask
{
    [_retval removeFromParentAndCleanup:NO];
    isActive = NO;
}
@end
