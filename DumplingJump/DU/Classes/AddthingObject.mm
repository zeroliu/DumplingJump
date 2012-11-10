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
#import "HeroManager.h"

@implementation AddthingObject
@synthesize reaction = _reaction;
@synthesize animation = _animation;

-(id) initWithID:(NSString *)theID name:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody canResize:(BOOL)resize reaction:(NSString *)reactionName animation:(NSString *)animationName;
{
    if (self = [super initWithName:theName file:theFile body:theBody canResize:resize]) {
        _reaction = [[ReactionManager shared] getReactionWithName:reactionName];
        _animation = animationName;
        
        self.ID = theID;
        [self setContactListener];
        [self setCountdownClean];
        [self setCountdownFunction];
        if (_animation != nil)
        {
            [self playAnimation];
        }
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
//    [MESSAGECENTER addObserver:self selector:@selector(EndContact:) name:[NSString stringWithFormat:@"%@EndContact",self.name] object:nil];
}

-(void) removeContactListener
{
    [MESSAGECENTER removeObserver:self name:[NSString stringWithFormat:@"%@Contact",self.ID] object:nil];
}

-(void) BeginContact:(NSNotification *)notification
{
    DUPhysicsObject *targetObject = (DUPhysicsObject *)([notification.userInfo objectForKey:@"object"]);
    /*
    
    */
    if (targetObject.name == HERO)
    {
        DLog(@"heroState = %@", ((Hero *)[HEROMANAGER getHero]).heroState);
        if ([((Hero *)[HEROMANAGER getHero]).heroState isEqualToString: @"shelter"])
        {
            for ( b2ContactEdge* contactEdge = self.body->GetContactList(); contactEdge; contactEdge = contactEdge->next )
            {
                contactEdge->contact->SetEnabled(false);
            }
            [self removeAddthingWithDel];
            
        } else
        {
            if (self.reaction != nil)
            {
                //If addthing touch hero
                //Hero reacts
                [HEROMANAGER heroReactWithReaction:self.reaction contactObject:self];
                
                //If addthing will disappear after touch the hero
                if (self.reaction.triggerCleanHero == 1)
                {
                    //               DLog(@"My ID is %@", self.ID);
                    [self removeAddthing];
                }
            }
        }
        //            DLog(@"%@ Touch Hero",self.name);
    } else if (targetObject.name == BOARD)
    {
        if (self.reaction != nil)
        {
            if (self.reaction.triggerCleanBoard == 1)
            {
                [self removeAddthing];
            }
        }
        //            DLog(@"%@ Touch Board",self.name);
    } else
    {
        if (self.reaction != nil)
        {
            if (self.reaction.triggerCleanWorld == 1)
            {
                [self removeAddthing];
            }
        }
    }
}

-(void) removeAddthingWithDel
{
    [PHYSICSMANAGER addToArchiveList:self];
    [EFFECTMANAGER PlayEffectWithName:FX_DEL position:self.sprite.position];
}

-(void) removeAddthing
{
    [PHYSICSMANAGER addToArchiveList:self];
    //If addthing needs to trigger an effect after touching the hero
    if (self.reaction.effectName != nil)
    {
        [EFFECTMANAGER PlayEffectWithName:self.reaction.effectName position:self.sprite.position];
    }
}

-(void) runAction:(SEL)theSelector target:(id)theTarget afterDelay:(ccTime)theDelay
{
    id delay = [CCDelayTime actionWithDuration:theDelay];
//    id funcWrapper = [CCCallFunc actionWithTarget:theTarget selector:theSelector];
    id funcWrapper = [CCCallFuncND actionWithTarget:theTarget selector:theSelector data:self.reaction];
    id sequence = [CCSequence actions:delay, funcWrapper, nil];
    [self.sprite runAction:sequence];
}

-(void) playAnimation
{
    id animate = [CCAnimate actionWithAnimation:[ANIMATIONMANAGER getAnimationWithName:self.animation]];
    [self.sprite runAction:[CCRepeatForever actionWithAction:animate]];
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
