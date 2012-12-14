//
//  BackgroundView.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//
#define SCROLL_SPEED 0.3
#define dy -0.3
#define W 320
#define H 480

#import "BackgroundView.h"
#import "BackgroundController.h"
#import "HeroManager.h"

@implementation BackgroundView
@synthesize bgBatchNode = _bgBatchNode, scrollSpeedScale = _scrollSpeedScale;

-(id) init
{
    if (self = [super init])
    {
        _scrollSpeedScale = 1;
    }
    
    return self;
}

-(void) setBgBatchNodeWithName:(NSString *)bgName
{
    [[[Hub shared]gameLayer] removeChild:self.bgBatchNode cleanup:NO];
    
    //Set the batchNode
    self.bgBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png",bgName]];
    
    [[[Hub shared]gameLayer] addChild:self.bgBatchNode];
}

-(void) setBackgroundWithBGArray:(NSMutableArray *)theArray;
{
    for(NSValue *anObject in theArray)
    {
        //Load one BgLayer
        BgLayer myLayer;
        [anObject getValue:&myLayer];
        
        //Set the sprite position of background sprite and swapSprite
        myLayer.sprite.position = ccp(W/2,H/2+myLayer.offset);
        [self.bgBatchNode addChild:myLayer.sprite z:myLayer.z];
        myLayer.swapSprite.position = ccp(W/2,H*3/2+myLayer.offset);
        [self.bgBatchNode addChild:myLayer.swapSprite z:myLayer.z];
    }
}

-(void) updateBackgroundWithBGArray:(NSMutableArray *)theArray
{
    for(NSValue *anObject in theArray)
    {
        BgLayer myLayer;
        [anObject getValue:&myLayer];
        
        float y = dy* _scrollSpeedScale * (myLayer.speedScale + ((Hero *)[[HeroManager shared] getHero]).body->GetLinearVelocity().y * ((120-myLayer.depth))/120);
        
        myLayer.sprite.position = ccpAdd(myLayer.sprite.position, ccp(0,y));
        myLayer.swapSprite.position = ccpAdd(myLayer.swapSprite.position, ccp(0,y));
        if(myLayer.sprite.position.y < -H/2) myLayer.sprite.position = ccp(W/2, H*3/2 + dy* _scrollSpeedScale*myLayer.speedScale);
        if(myLayer.swapSprite.position.y < -H/2) myLayer.swapSprite.position = ccp(W/2, H*3/2 + dy* _scrollSpeedScale*myLayer.speedScale);
        //        NSLog(@"sprite pos y = %f, swapsprite pos y = %g", myLayer.sprite.position.y, myLayer.swapSprite.position.y);
    }
}

@end
