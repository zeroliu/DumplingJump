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
#import "HeroManager.h"
#import "Hero.h"
#import "GameModel.h"
#import "CameraEffects.h"
@interface BackgroundManager()
{
    NSMutableDictionary*    _backgroundData;
    
    //Data structure
    //<stage number>    -> NSArray
    //                      -> NSDictionary
    //                      -> NSDictionary
    //<stage number>    -> NSArray
    //                      -> NSDictionary
    //                      -> NSDictionary
    ///...
    NSMutableDictionary*    _backgroundObjectData;
    
    CCSpriteBatchNode*      _bgNode;
    CCSpriteBatchNode*      _bgObjectNode;
    
    CCSprite*               _belowBG;
    CCSprite*               _aboveBG;
    
    NSMutableDictionary*    _belowSprites;
    NSMutableDictionary*    _aboveSprites;
    NSMutableArray*         _currentObjects;
    NSArray*                _newObjects;
    NSMutableArray*         _objectToRemove;
    
    int                     _currentStage;
    int                     _maxStage;
    float                   _currentBgVelocity;
    
    float                   _winHeight;
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
    [_belowSprites release];
    _belowSprites = nil;
    [_aboveSprites release];
    _aboveSprites = nil;
    [_currentObjects release];
    _currentObjects = nil;
    [_newObjects release];
    _newObjects = nil;
    [_objectToRemove release];
    _objectToRemove = nil;
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
        
        _belowSprites = [[NSMutableDictionary alloc] init];
        _aboveSprites = [[NSMutableDictionary alloc] init];
        _currentObjects = [[NSMutableArray alloc] init];
        _objectToRemove = [[NSMutableArray alloc] init];
        
        _winHeight = [CCDirector sharedDirector].winSize.height - BLACK_HEIGHT * 2;
        _newObjects = nil;
    }
    
    return self;
}

#pragma mark -
#pragma mark public
- (void) addBackgroundToLayer
{
    if (![[[[WorldData shared] loadDataWithAttributName:@"debug"] objectForKey:@"physicsDebug"] boolValue])
    {
        [GAMELAYER addChild:self];
        [GAMELAYER addChild:_bgNode z:1];
        [GAMELAYER addChild:_bgObjectNode z:2];
    }
}

- (void) reset
{
    //Reset nodes position
    _bgNode.position = CGPointZero;
    _bgObjectNode.position = CGPointZero;
    
    //Remove all existing sprites
    [_bgObjectNode removeAllChildrenWithCleanup:NO];
    
    //Reset stage number
    _currentStage = 1;
    
    //Reset scroll speed scale
    _scrollSpeedScale = 1;
    
    //Reset background objects
    [_currentObjects removeAllObjects];
    
    //Add background objects for stage 1
    [_currentObjects addObjectsFromArray:[_backgroundObjectData objectForKey:[NSString stringWithFormat:@"%d",_currentStage]]];
    
    //Recreate background sprites
    [self resetBackgroundSprites];
    
    //Recreate background object sprites
    [self resetBackgroundObjectSprites];
    
    [self updateCurrentBGVelocity];
    
    if (_newObjects != nil)
    {
        [_newObjects release];
        _newObjects = nil;
    }
    
    [_objectToRemove removeAllObjects];
}

- (void) updateBackgroundPosition:(ccTime)deltaTime
{
    float dy = -GAMEMODEL.scrollSpeedIncrease * MAX(1, _scrollSpeedScale/2.5) * _currentBgVelocity * deltaTime;
    _belowBG.position = ccpAdd(_belowBG.position, ccp(0,dy));
    _aboveBG.position = ccp(0, _belowBG.position.y + _belowBG.boundingBox.size.height-1);
    
    //If going out of the boundary, switch position
    if (_aboveBG.position.y < BLACK_HEIGHT)
    {
        [self swapBGSpritePointer:&_aboveBG with:&_belowBG];
        if (_currentStage < _maxStage)
        {
            _currentStage ++;
            [self addTransitionSpriteToCurrentObject];
            [self loadNewObjectData];
            [self addNewBackgroundObjectsWithNewObjectData:_newObjects];
            [self updateCurrentBGVelocity];
            [self setNewBackgroundSprite];
        }
    }
}

- (void) updateBackgroundObjectPosition:(ccTime)deltaTime
{
    for (NSDictionary* objectData in _currentObjects)
    {
        float initYPos = [[objectData objectForKey:@"y"] floatValue];
        float currentVelocity = _winHeight / [[objectData objectForKey:@"time"] floatValue];
        float dy = -GAMEMODEL.scrollSpeedIncrease * _scrollSpeedScale * currentVelocity * deltaTime;
        
        //Hero Influence
        float heroVy = ((Hero *)[[HeroManager shared] getHero]).body->GetLinearVelocity().y;
        float influence = heroVy/2 * [[objectData objectForKey:@"hero_influence"] floatValue];
        
        dy = dy - MAX(influence,-2);
        
        NSString *objectID = [objectData objectForKey:@"id"];
        CCSprite *belowSprite = [_belowSprites objectForKey:objectID];
        CCSprite *aboveSprite = [_aboveSprites objectForKey:objectID];
        belowSprite.position = ccpAdd(belowSprite.position, ccp(0,dy));
        aboveSprite.position = ccp(aboveSprite.position.x, belowSprite.position.y + _winHeight - 1);
        
        if (aboveSprite.position.y < initYPos + BLACK_HEIGHT)
        {
            int objectStage = [[objectData objectForKey:@"stage"] intValue];
            if (objectStage == _currentStage)
            {
                [_belowSprites setObject:aboveSprite forKey:objectID];
                [_aboveSprites setObject:belowSprite forKey:objectID];
            }
            
            // if above layer moves out of the screen
            if (aboveSprite.position.y < initYPos + BLACK_HEIGHT - _winHeight)
            {
                if ([[aboveSprite children] count] > 0)
                {
                    float childHeightMax = 0;
                    for (id child in [aboveSprite children])
                    {
                        if ([child isKindOfClass:[CCSprite class]])
                        {
                            childHeightMax = MAX(((CCSprite *)child).boundingBox.size.height, childHeightMax);
                        }
                    }
                    if (aboveSprite.position.y < initYPos + BLACK_HEIGHT - _winHeight - childHeightMax)
                    {
                        [_objectToRemove addObject:objectData];
                    }
                }
                else
                {
                    [_objectToRemove addObject:objectData];
                }
            }
        }
    }
    
    if ([_objectToRemove count] > 0)
    {
        for (NSDictionary* toRemoveObject in _objectToRemove)
        {
            NSString *objectID = [toRemoveObject objectForKey:@"id"];
            [_currentObjects removeObject:toRemoveObject];
            [[_belowSprites objectForKey:objectID] removeFromParentAndCleanup:NO];
            [[_aboveSprites objectForKey:objectID] removeFromParentAndCleanup:NO];
            [_belowSprites removeObjectForKey:objectID];
            [_aboveSprites removeObjectForKey:objectID];
        }
        
        [_objectToRemove removeAllObjects];
    }

    if (_newObjects != nil)
    {
        [_currentObjects addObjectsFromArray:_newObjects];
        [_newObjects release];
        _newObjects = nil;
    }
}

-(void) speedUpWithScale:(int)scale interval:(float)time
{
    [self stopAllActions];
    id speedScaleUp = [CCActionTween actionWithDuration:0.5 key:@"scrollSpeedScale" from:1 to:scale];
    id delay = [CCDelayTime actionWithDuration:time];
    id speedScaleDown = [CCActionTween actionWithDuration:0.2 key:@"scrollSpeedScale" from:scale to:1];
    id sequence = [CCSequence actions:speedScaleUp, delay, speedScaleDown, nil];
    [self runAction:sequence];
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

- (void) resetBackgroundObjectSprites
{
    [_bgObjectNode removeAllChildrenWithCleanup:NO];
    
    [_belowSprites removeAllObjects];
    [_aboveSprites removeAllObjects];
    
    for (NSDictionary* objectData in _currentObjects)
    {
        NSString *objectID = [objectData objectForKey:@"id"];
        NSString *spriteName = [objectData objectForKey:@"name"];
        CCSprite* belowSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",spriteName]];
        CCSprite* aboveSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",spriteName]];
        
        float anchorX = [[objectData objectForKey:@"anchorX"] floatValue];
        float x = [[objectData objectForKey:@"x"] floatValue];
        float y = [[objectData objectForKey:@"y"] floatValue];
        belowSprite.anchorPoint = ccp(anchorX,0);
        belowSprite.position = ccp(x, y + BLACK_HEIGHT);
        aboveSprite.anchorPoint = ccp(anchorX,0);
        aboveSprite.position = ccp(x, belowSprite.position.y + _winHeight - 1);
        
        [_belowSprites setObject:belowSprite forKey:objectID];
        [_aboveSprites setObject:aboveSprite forKey:objectID];
        
        int layer = [[objectData objectForKey:@"z"] intValue];
        [_bgObjectNode addChild:belowSprite z:layer];
        [_bgObjectNode addChild:aboveSprite z:layer];
    }
}

- (void) addNewBackgroundObjectsWithNewObjectData:(NSArray *)newObjects
{
    for (NSDictionary* objectData in newObjects)
    {
        NSString *objectID = [objectData objectForKey:@"id"];
        NSString *spriteName = [objectData objectForKey:@"name"];
        CCSprite* belowSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",spriteName]];
        CCSprite* aboveSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",spriteName]];
        
        float anchorX = [[objectData objectForKey:@"anchorX"] floatValue];
        float x = [[objectData objectForKey:@"x"] floatValue];
        float y = [[objectData objectForKey:@"y"] floatValue];
        belowSprite.anchorPoint = ccp(anchorX,0);
        belowSprite.position = ccp(x, y + BLACK_HEIGHT + _winHeight);
        aboveSprite.anchorPoint = ccp(anchorX,0);
        aboveSprite.position = ccp(x, belowSprite.position.y + _winHeight*2 - 1);
        
        [_belowSprites setObject:belowSprite forKey:objectID];
        [_aboveSprites setObject:aboveSprite forKey:objectID];
        
        int layer = [[objectData objectForKey:@"z"] intValue];
        [_bgObjectNode addChild:belowSprite z:layer];
        [_bgObjectNode addChild:aboveSprite z:layer];
    }
}

- (void) updateCurrentBGVelocity
{
    float duration = [[[_backgroundData objectForKey:[NSString stringWithFormat:@"%d",_currentStage]] objectForKey:@"time"] floatValue];
    _currentBgVelocity = _winHeight / duration;
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

- (void) loadNewObjectData
{
    _newObjects = [[_backgroundObjectData objectForKey:[NSString stringWithFormat:@"%d",_currentStage]] retain];
}

- (void) addTransitionSpriteToCurrentObject
{
    for (NSDictionary* objectData in _currentObjects)
    {
        NSString *transitionSpriteName = [objectData objectForKey:@"transition"];
        if (transitionSpriteName != nil && ![transitionSpriteName isEqualToString:@""])
        {
            NSString *objectID = [objectData objectForKey:@"id"];
            CCSprite* transitionSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",transitionSpriteName]];
            transitionSprite.anchorPoint = ccp(0,0);
            CCSprite* aboveSprite = [_aboveSprites objectForKey:objectID];
            transitionSprite.position = ccp(0,aboveSprite.boundingBox.size.height-1);
            [aboveSprite addChild:transitionSprite];
        }
    }
}

- (void) shakeBackgroundWithX:(float)amountX y:(float)amountY duration:(float)time
{
    [[CameraEffects shared] shakeCameraWithTarget:_bgNode x:amountX y:amountY duration:time];
    [[CameraEffects shared] shakeCameraWithTarget:_bgObjectNode x:amountX y:amountY duration:time];
}
@end
