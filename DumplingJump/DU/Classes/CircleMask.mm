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

- (void)dealloc
{
    [_maskSprite release];
    _maskSprite = nil;
    [_textureSprite release];
    _textureSprite = nil;
    [_retval release];
    _retval = nil;
    [rt release];
    rt = nil;
    [super dealloc];
}

-(id) initWithTexture:(CCSprite *)textureSprite Mask:(CCSprite *)maskSprite
{
    if (self = [super init])
    {
        _textureSprite = [textureSprite retain];
        _maskSprite = [maskSprite retain];
        isActive = false;
    }
    
    return self;
}

- (CCSprite *)maskedSpriteWithSprite:(CGPoint)pos
{
    // 1
    rt = [[CCRenderTexture renderTextureWithWidth:_textureSprite.contentSize.width height:_textureSprite.contentSize.height] retain];
    
    // 2
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
    _retval = [[CCSprite spriteWithTexture:rt.sprite.texture] retain];
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
    [_retval release];
    _retval = nil;
    isActive = NO;
}
@end
