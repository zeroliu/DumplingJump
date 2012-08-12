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
#define H 530

#import "BackgroundView.h"
#import "BackgroundController.h"

@implementation BackgroundView
@synthesize bgBatchNode = _bgBatchNode;

-(void) setBgBatchNodeWithName:(NSString *)bgName
{
    [[[Hub shared]gameLayer] removeChild:self.bgBatchNode cleanup:YES];
    
    //Set the batchNode
    self.bgBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.pvr",bgName]];
    
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
        
        myLayer.sprite.position = ccpAdd(myLayer.sprite.position, ccp(0,dy*myLayer.speedScale));
        myLayer.swapSprite.position = ccpAdd(myLayer.swapSprite.position, ccp(0,dy*myLayer.speedScale));
        if(myLayer.sprite.position.y < -H/2) myLayer.sprite.position = ccp(W/2, H*3/2 + dy*myLayer.speedScale);
        if(myLayer.swapSprite.position.y < -H/2) myLayer.swapSprite.position = ccp(W/2, H*3/2 + dy*myLayer.speedScale);
        //        NSLog(@"sprite pos y = %f, swapsprite pos y = %g", myLayer.sprite.position.y, myLayer.swapSprite.position.y);
    }
}

@end
