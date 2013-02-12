//
//  BackgroundView.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//
#define W 320
#define H 480

#import "BackgroundView.h"
#import "BackgroundController.h"
#import "HeroManager.h"
#import "GameModel.h"

@interface BackgroundView()
{
    float dy;
    CGSize winSize;
}
@end

@implementation BackgroundView
@synthesize bgBatchNode = _bgBatchNode, scrollSpeedScale = _scrollSpeedScale;

-(id) init
{
    if (self = [super init])
    {
        _scrollSpeedScale = 1;
        dy = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"scrollSpeed"] floatValue];
        winSize = [[CCDirector sharedDirector] winSize];
    }
    
    return self;
}

-(void) setBgBatchNodeWithName:(NSString *)bgName
{
    [[[Hub shared]gameLayer] removeChild:self.bgBatchNode cleanup:NO];
    
    //Set the batchNode
    self.bgBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png",bgName]];
    
    [GAMELAYER addChild:self];
    [GAMELAYER addChild:self.bgBatchNode];
}

-(void) setBackgroundWithBGArray:(NSMutableArray *)theArray;
{
    for(NSValue *anObject in theArray)
    {
        //Load one BgLayer
        BgLayer myLayer;
        [anObject getValue:&myLayer];
        
        //Set the sprite position of background sprite and swapSprite
        myLayer.sprite.position = ccp(winSize.width/2,winSize.height/2+myLayer.offset);
        [self.bgBatchNode addChild:myLayer.sprite z:myLayer.z];
        myLayer.swapSprite.position = ccp(winSize.width/2,winSize.height/2+myLayer.swapSprite.boundingBox.size.height+myLayer.offset);
        [self.bgBatchNode addChild:myLayer.swapSprite z:myLayer.z];
    }
}

-(void) updateBackgroundWithBGArray:(NSMutableArray *)theArray
{
    for(NSValue *anObject in theArray)
    {
        BgLayer myLayer;
        [anObject getValue:&myLayer];
        
        float y = dy * GAMEMODEL.gameSpeed * _scrollSpeedScale * (myLayer.speedScale + ((Hero *)[[HeroManager shared] getHero]).body->GetLinearVelocity().y * ((120-myLayer.depth))/120);
        
        myLayer.sprite.position = ccpAdd(myLayer.sprite.position, ccp(0,y));
        myLayer.swapSprite.position = ccpAdd(myLayer.swapSprite.position, ccp(0,y));
        if(myLayer.sprite.position.y < winSize.height/2-myLayer.sprite.boundingBox.size.height)
        {
            //myLayer.sprite.position = ccp(W/2, H*3/2 + dy* _scrollSpeedScale*myLayer.speedScale);
            myLayer.sprite.position = ccp(winSize.width/2, myLayer.swapSprite.position.y + myLayer.swapSprite.boundingBox.size.height);
        }
        if(myLayer.swapSprite.position.y < winSize.height/2-myLayer.sprite.boundingBox.size.height)
        {
            //myLayer.swapSprite.position = ccp(W/2, H*3/2 + dy* _scrollSpeedScale*myLayer.speedScale);
            myLayer.swapSprite.position = ccp(winSize.width/2, myLayer.sprite.position.y + myLayer.sprite.boundingBox.size.height);
        }
        //        NSLog(@"sprite pos y = %f, swapsprite pos y = %g", myLayer.sprite.position.y, myLayer.swapSprite.position.y);
    }
}

- (void)dealloc
{
    [self.bgBatchNode release];
    [super dealloc];
}

@end
