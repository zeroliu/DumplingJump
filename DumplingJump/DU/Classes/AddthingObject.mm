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

-(id) initWithID:(NSString *)theID name:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody canResize:(BOOL)resize reaction:(NSString *)reactionName;
{
    if (self = [super initWithName:theName file:theFile body:theBody canResize:resize]) {
        _reaction = [[ReactionManager shared] getReactionWithName:reactionName];
        self.ID = theID;
        [self setContactListener];
        [self setCountdownClean];
        [self setCountdownFunction];
    }
    
    return self;
}

-(void) setCountdownClean
{
    if (self.reaction.cleanTime >= 0)
    {
        [self runAction:@selector(removeAddthing) target:self afterDelay:self.reaction.cleanTime];
    }
}

-(void) setCountdownFunction
{
    //If the addthing has a countdown feature
    if (self.reaction.reactTime >= 0 && self.reaction.reactTimeSelectorName != nil)
    {
        SEL callback = NSSelectorFromString(self.reaction.reactTimeSelectorName);
        
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

-(void)BeginContact:(NSNotification *)notification
{
    DUPhysicsObject *targetObject = (DUPhysicsObject *)([notification.userInfo objectForKey:@"object"]);
    
    if (self.reaction != nil)
    {
        if (targetObject.name == HERO)
        {
            //If addthing touch hero
            //Hero reacts
            [HEROMANAGER heroReactWithReaction: self.reaction];
            
            //If addthing will disappear after touch the hero
            if (self.reaction.triggerCleanHero == 1)
            {
//                DLog(@"My ID is %@", self.ID);
                [self removeAddthing];
            }

//            DLog(@"%@ Touch Hero",self.name);
        } else if (targetObject.name == BOARD)
        {
            if (self.reaction.triggerCleanBoard == 1)
            {
                [self removeAddthing];
            }
//            DLog(@"%@ Touch Board",self.name);
        }
    }
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
    id funcWrapper = [CCCallFunc actionWithTarget:theTarget selector:theSelector];
    id sequence = [CCSequence actions:delay, funcWrapper, nil];
    [self.sprite runAction:sequence];
}

-(void) activate
{
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
