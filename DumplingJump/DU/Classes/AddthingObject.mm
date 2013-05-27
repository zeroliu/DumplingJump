//
//  AddthingObject.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-14.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "AddthingObject.h"
#import "ReactionFunctions.h"
#import "GameLayer.h"
#import "GameModel.h"
#import "GameUI.h"
#import "HeroManager.h"
#import "LevelManager.h"
#import "CCBReader.h"
#import "CCParticleSystemQuad.h"
#import "InterReactionManager.h"
#import "LevelManager.h"

@interface AddthingObject()
{
    BOOL _isRemoved;
    BOOL _hasPlayedFirstTouchSFX;
}
@end

@implementation AddthingObject
@synthesize reaction = _reaction;
@synthesize animation = _animation;
@synthesize wait = _wait;
@synthesize warningTime = _warningTime;
@synthesize firstTouchSFX = _firstTouchSFX;

- (void)dealloc
{
    [self.animation release];
    [self.reaction release];
    [self.firstTouchSFX release];
    
    [super dealloc];
}

-(id) initWithID:(NSString *)theID name:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody canResize:(BOOL)resize reaction:(NSString *)reactionName animation:(NSString *)animationName wait:(double)waitTime warningTime:(double)warningTime firstTouchSFX:(NSString *)firstTouchSFX
{
    if (self = [super initWithName:theName file:theFile body:theBody canResize:resize])
    {
        self.reaction = [[ReactionManager shared] getReactionWithName:reactionName];
        self.animation = animationName;
        _isRemoved = NO;
        _wait = waitTime;
        _warningTime = warningTime;
        self.firstTouchSFX = firstTouchSFX;
        
        self.ID = theID;
        [self setContactListener];
        [self setCountdownClean];
        [self setCountdownFunction];
        if (_animation != nil)
        {
            [self playAnimation];
        }
        
        _hasPlayedFirstTouchSFX = NO;
    }
    return self;
}

-(void) setCountdownClean
{
    if (self.reaction != nil && self.reaction.cleanTime >= 0)
    {
        [self runAction:@selector(removeAddthing) target:self afterDelay:self.reaction.cleanTime];
    }
}

-(void) setCountdownFunction
{
    //If the addthing has a countdown feature
    if (self.reaction != nil && self.reaction.reactTime >= 0 && self.reaction.reactTimeSelectorName != nil)
    {
        SEL callback = NSSelectorFromString([NSString stringWithFormat:@"%@:data:", self.reaction.reactTimeSelectorName]);
        DLog(@"%@", NSStringFromSelector(callback));
        [self runAction:callback target:REACTIONFUNCTIONS afterDelay:self.reaction.reactTime];
    }
}

-(void) setContactListener
{
    [MESSAGECENTER addObserver:self selector:@selector(BeginContact:) name:[NSString stringWithFormat:@"%@Contact",self.ID] object:nil];
}

-(void) removeContactListener
{
    [MESSAGECENTER removeObserver:self name:[NSString stringWithFormat:@"%@Contact",self.ID] object:nil];
}

-(void) BeginContact:(NSNotification *)notification
{
    DUPhysicsObject *targetObject = (DUPhysicsObject *)([notification.userInfo objectForKey:@"object"]);
    
    if ([targetObject.name isEqualToString: HERO])
    {
        //check destroy case
        
        if ([((Hero *)[HEROMANAGER getHero]) isShelterOn] || ((Hero *)[HEROMANAGER getHero]).isSpringBoost || [((Hero *)[HEROMANAGER getHero]) isBoosterOn])
        {
            if (![self.name isEqualToString:@"STAR"] && ![self.name isEqualToString:@"MEGA"])
            {
                for ( b2ContactEdge* contactEdge = self.body->GetContactList(); contactEdge; contactEdge = contactEdge->next )
                {
                    contactEdge->contact->SetEnabled(false);
                }
                [self removeAddthingWithDel];
                
                [GAMEMODEL addStarWithNum:[[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"starMultiplier"] floatValue]];
                [[GameUI shared] updateStar:GAMEMODEL.star];
                [[LevelManager shared] generateFloatingStar:self.sprite.position];
            }
            else
            {
                [HEROMANAGER heroReactWithReaction:self.reaction contactObject:self];
                
                //If addthing will disappear after touch the hero
                if (self.reaction.triggerCleanHero == 1)
                {
                    [self removeAddthing];
                }
            }
            
            return;
        }

        if (self.reaction != nil)
        {
            //If addthing touch hero
            //Hero reacts
            [HEROMANAGER heroReactWithReaction:self.reaction contactObject:self];
            
            //If addthing will disappear after touch the hero
            if (self.reaction.triggerCleanHero == 1)
            {
                //DLog(@"My ID is %@", self.ID);
                [self removeAddthing];
            }
            else
            {
                [self playFirstTouchSFX];
            }
        }
        else
        {
            [self playFirstTouchSFX];
        }
        
        //            DLog(@"%@ Touch Hero",self.name);
    } else if ([targetObject.name isEqualToString: BOARD])
    {
        if (self.reaction != nil)
        {
            if (self.reaction.triggerCleanBoard == 1)
            {
                [self removeAddthing];
            }
            else
            {
                [self playFirstTouchSFX];
            }
        }
        else
        {
            [self playFirstTouchSFX];
        }
        //            DLog(@"%@ Touch Board",self.name);
    } else if ([targetObject.name isEqualToString:@"SLASH"])
    {
        [GAMEMODEL addStarWithNum:[[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"starMultiplier"] floatValue]];
        [[LevelManager shared] generateFloatingStar:self.sprite.position];
        [[GameUI shared] updateStar:GAMEMODEL.star];
        [self removeAddthingWithDel];
    } else
    {
        if (self.reaction != nil)
        {
            if (self.reaction.triggerCleanWorld == 1)
            {
                [self removeAddthing];
            }
            else
            {
                [self playFirstTouchSFX];
            }
        }
        else
        {
            [self playFirstTouchSFX];
        }
    }
}

-(void) playFirstTouchSFX
{
    if (!_hasPlayedFirstTouchSFX && self.firstTouchSFX != nil)
    {
        _hasPlayedFirstTouchSFX = YES;
        [[AudioManager shared] playSFX:[NSString stringWithFormat:@"sfx_castleRider_%@.mp3", self.firstTouchSFX]];
    }
}

-(void) removeAddthingWithoutAnimation
{
    [[LevelManager shared] removeObjectFromList:self];
    [PHYSICSMANAGER addToArchiveList:self];
}

-(void) removeAddthingWithDel
{
    [[LevelManager shared] removeObjectFromList:self];
    [PHYSICSMANAGER addToArchiveList:self];
    [EFFECTMANAGER PlayEffectWithName:FX_DEL position:self.sprite.position];
}

-(void) removeAddthing
{
    if (!_isRemoved)
    {
        _isRemoved = YES;
        [[LevelManager shared] removeObjectFromList:self];
        [PHYSICSMANAGER addToArchiveList:self];
        //If addthing needs to trigger an effect after touching the hero
        
        if ([self.name isEqualToString:@"STAR"])
        {
            CCNode *particleNode = [[DUParticleManager shared] createParticleWithName:@"FX_coinstarGet.ccbi" parent:GAMELAYER z:20];
            particleNode.position = self.sprite.position;
        }
        else if ([self.name isEqualToString:@"MEGA"])
        {
            CCNode *particleNode = [[DUParticleManager shared] createParticleWithName:@"FX_itemGet.ccbi" parent:GAMELAYER z:20];
            particleNode.position = self.sprite.position;
        }
        else if ([self.reaction.effectName isEqualToString:@"FX_Powder"])
        {
            [EFFECTMANAGER PlayEffectWithName:self.reaction.effectName position:self.sprite.position z:Z_Engine+1 parent:BATCHNODE];
        }
        else if (![self.reaction.effectName isEqualToString:@"NULL"] && self.reaction.effectName != nil)
        {
            [EFFECTMANAGER PlayEffectWithName:self.reaction.effectName position:self.sprite.position];
        }
    }
}

-(void) moveToHeroWithSpeed:(int)theSpeed
{
    Hero *hero = [[HeroManager shared] getHero];
    float ratio = ccpDistance(hero.sprite.position, self.sprite.position) / 7;
    CGPoint direction = ccp((hero.sprite.position.x - self.sprite.position.x)/ratio, (hero.sprite.position.y - self.sprite.position.y)/ratio);
    self.sprite.position = ccpAdd(self.sprite.position, direction);
    
    if (ccpDistance(hero.sprite.position, self.sprite.position) < 3)
    {
        [self unschedule:@selector(moveToHeroWithSpeed:)];
        float addStarNum = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"starMultiplier"] floatValue];
        if ([self.name isEqualToString:@"ROYALSTAR"])
        {
            addStarNum = addStarNum * 2;
        }
        [GAMEMODEL addStarWithNum:addStarNum];
        [[GameUI shared] updateStar:((GameLayer *)GAMELAYER).model.star];
        [self removeFromParentAndCleanup:YES];
        [self removeAddthing];
    }
}

-(void) runAction:(SEL)theSelector target:(id)theTarget afterDelay:(ccTime)theDelay
{
    id delay = [CCDelayTime actionWithDuration:theDelay];
    id funcWrapper = [CCCallFuncND actionWithTarget:theTarget selector:theSelector data:self.reaction];
    id sequence = [CCSequence actions:delay, funcWrapper, nil];
    [self.sprite runAction:sequence];
}

-(void) playAnimation
{
    id animate = [CCAnimate actionWithAnimation:[ANIMATIONMANAGER getAnimationWithName:self.animation]];
    [self.sprite runAction:[CCRepeatForever actionWithAction:animate]];
}

-(void) archive
{
    if ([self.name isEqualToString:@"POWDER"] || [self.name isEqualToString:@"BOMB"])
    {
        [((LevelManager *)[LevelManager shared]).toRemovePowderArray addObject:self.ID];
    }
    [super archive];
}

-(void) activate
{
    if (_animation != nil)
    {
        [self playAnimation];
    }
    [self setCountdownClean];
    [self setCountdownFunction];
    [self setContactListener];
    [super activate];
}

-(void) deactivate
{
    [self removeContactListener];
    [super deactivate];
}

@end
