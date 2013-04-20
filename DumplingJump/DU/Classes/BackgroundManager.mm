//
//  BackgroundManager.m
//  CastleRider
//
//  Created by zero.liu on 4/19/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "BackgroundManager.h"
#import "XMLHelper.h"
#import "Constants.h"
#import "Common.h"
#import "GameModel.h"
@interface BackgroundManager()
{
    NSMutableDictionary*    _backgroundData;
    NSMutableDictionary*    _backgroundObjectData;
    
    CCSpriteBatchNode*      _bgNode;
    CCSpriteBatchNode*      _bgObjectNode;
    
    CCSprite*               _belowBG;
    CCSprite*               _aboveBG;
    
    int                     _currentStage;
    int                     _maxStage;
    float                   _currentBgVelocity;
}
@property (nonatomic, assign) float scrollSpeedScale;
@end

@implementation BackgroundManager
@synthesize
scrollSpeedScale = _scrollSpeedScale;

#pragma mark -
#pragma mark inherit
- (void)dealloc
{
    [_backgroundData release];
    _backgroundData = nil;
    [_backgroundObjectData release];
    _backgroundObjectData = nil;
    [_bgNode release];
    _bgNode = nil;
    [_bgObjectNode release];
    _bgObjectNode = nil;
    [_belowBG release];
    _belowBG = nil;
    [_aboveBG release];
    _aboveBG = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark public static
+ (id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[BackgroundManager alloc] init];
    }
    
    return shared;
}

#pragma mark -
#pragma mark initialization
- (id) init
{
    if (self = [super init])
    {
        _backgroundData = [[[XMLHelper shared] loadBackgroundData] retain];
        _backgroundObjectData = [[[XMLHelper shared] loadBackgroundObjectData] retain];
        _maxStage = [_backgroundData count];
        
        //Add background plist to the frame cache
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetBackground.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetBackgroundObject.plist"];
        
        //Set batch node
        _bgNode = [[CCSpriteBatchNode batchNodeWithFile:@"sheetBackground.png"] retain];
        _bgObjectNode = [[CCSpriteBatchNode batchNodeWithFile:@"sheetBackgroundObject.png"] retain];
    }
    
    return self;
}

#pragma mark -
#pragma mark public
- (void) addBackgroundToLayer
{
    if (![[[[WorldData shared] loadDataWithAttributName:@"debug"] objectForKey:@"physicsDebug"] boolValue])
    {
        [GAMELAYER addChild:_bgNode z:1];
        [GAMELAYER addChild:_bgObjectNode z:2];
    }
}

- (void) reset
{
    //Remove all existing sprites
    [_bgObjectNode removeAllChildrenWithCleanup:NO];
    
    //Reset stage number
    _currentStage = 1;
    
    //Reset scroll speed scale
    _scrollSpeedScale = 1;
    
    //Recreate background sprites
    [self resetBackgroundSprites];
    
    [self updateCurrentBGVelocity];
}

- (void) updateBackgroundPosition:(ccTime)deltaTime
{
    float dy = -GAMEMODEL.scrollSpeedIncrease * _scrollSpeedScale * _currentBgVelocity * deltaTime;
    _belowBG.position = ccpAdd(_belowBG.position, ccp(0,dy));
    _aboveBG.position = ccp(0, _belowBG.position.y + _belowBG.boundingBox.size.height-1);
    
    //If going out of the boundary, switch position
    if (_aboveBG.position.y < 0)
    {
        [self swapBGSpritePointer:&_aboveBG with:&_belowBG];
        if (_currentStage < _maxStage)
        {
            _currentStage ++;
            [self updateCurrentBGVelocity];
            [self setNewBackgroundSprite];
        }
    }
}

#pragma mark -
#pragma mark private
- (void) resetBackgroundSprites
{
    [_bgNode removeAllChildrenWithCleanup:NO];
    
    if (_belowBG != nil)
    {
        [_belowBG release];
        _belowBG = nil;
    }
    
    if (_aboveBG != nil)
    {
        [_aboveBG release];
        _aboveBG = nil;
    }
    
    _belowBG = [[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",[[_backgroundData objectForKey:[NSString stringWithFormat:@"%d",_currentStage]] objectForKey:@"name"]]] retain];
    _aboveBG = [[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",[[_backgroundData objectForKey:[NSString stringWithFormat:@"%d",_currentStage+1]] objectForKey:@"name"]]] retain];
    _belowBG.anchorPoint = ccp(0,0);
    _aboveBG.anchorPoint = ccp(0,0);
    _belowBG.position = ccp(0, BLACK_HEIGHT);
    _aboveBG.position = ccp(0, _belowBG.boundingBox.size.height-1);
    
    [_bgNode addChild:_belowBG];
    [_bgNode addChild:_aboveBG];
}

- (void) updateCurrentBGVelocity
{
    float screenHeight = [CCDirector sharedDirector].winSize.height - BLACK_HEIGHT * 2;
    float duration = [[[_backgroundData objectForKey:[NSString stringWithFormat:@"%d",_currentStage]] objectForKey:@"time"] floatValue];
    _currentBgVelocity = screenHeight / duration;
}

- (void) swapBGSpritePointer:(CCSprite **)spriteA with:(CCSprite **)spriteB
{
    CCSprite *swap = *spriteA;
    *spriteA = *spriteB;
    *spriteB = swap;
}

- (void) setNewBackgroundSprite
{
    [_aboveBG setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@.png",[[_backgroundData objectForKey:[NSString stringWithFormat:@"%d",MIN(_currentStage+1, _maxStage)]] objectForKey:@"name"]]]];
}

@end
