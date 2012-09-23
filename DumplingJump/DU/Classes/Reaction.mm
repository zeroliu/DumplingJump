//
//  Reaction.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-13.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//
//Step on feature is not implemented, Don't use it

#import "Reaction.h"

@implementation Reaction
@synthesize 
name = _name, //Reaction name
heroReactAnimationName = _heroReactAnimationName, //The animation needs to be played when touch hero
effectName = _effectName, //The animation needs to be played when taking effect
reactHeroSelectorName = _reactHeroSelectorName, //The selector will be called if addthings touch hero(above hero)
reactHeroSelectorParam = _reactHeroSelectorParam, //The parameter of the previous selector
reactHeroStepOnSelectorName = _reactHeroStepOnSelectorName, //The selector will be called if hero step on the addthings
reactHeroStepOnSelectorParam = _reactHeroStepOnSelectorParam, 
reactWorldSelectorName = _reactWorldSelectorName, //The selector will be called if addthings touch anything else
reactWorldSelectorParam = _reactWorldSelectorParam,
reactTimeSelectorName = _reactTimeSelectorName, //The selector will be called if time is up
reactionLasting = _reactionLasting, //How long does it last
reactTime = _reactTime, //How long does it take to trigger the reactTimeSelector
cleanTime = _cleanTime, //How long does it take to make the addthing disappear by itself
triggerCleanHero = _triggerCleanHero, //1 => Addthing get removed after touch the hero. Any other numbers => nothing happens
triggerCleanHeroStepOn = _triggerCleanHeroStepOn, //1 => Addthing get removed after hero steps on it
triggerCleanWorld = _triggerCleanWorld,
triggerCleanBoard = _triggerCleanBoard;

-(id) initWithName              :(NSString *)theName 
heroReactAnimationName          :(NSString *)theHeroReactAnimationName 
effectName             :(NSString *)theEffectName 
reactHeroSelectorName           :(NSString *)theReactHeroSelectorName
reactHeroSelectorParam          :(NSString *)theReactHeroSelectorParam
reactHeroStepOnSelectorName     :(NSString *)theReactHeroStepOnSelectorName
reactHeroStepOnSelectorParam    :(NSString *)theReactHeroStepOnSelectorParam
reactWorldSelectorName          :(NSString *)theReactWorldSelectorName
reactWorldSelectorParam         :(NSString *)theReactWorldSelectorParam
reactTimeSelectorName           :(NSString *)theReactTimeSelectorName
reactionLasting                 :(double) theReactionLasting
reactTime                       :(double) theReactTime
cleanTime                       :(double) theCleanTime
triggerCleanHero                :(int) theTriggerCleanHero
triggerCleanHeroStepOn          :(int) theTriggerCleanHeroStepOn
triggerCleanWorld               :(int)theTriggerCleanWorld
triggerCleanBoard               :(int)theTriggerCleanBoard
{
    if (self = [super init])
    {
        _name = theName;
        _heroReactAnimationName = theHeroReactAnimationName;
        _effectName = theEffectName;
        _reactHeroSelectorName = theReactHeroSelectorName;
        _reactHeroSelectorParam = theReactHeroSelectorParam;
        _reactHeroStepOnSelectorName = theReactHeroStepOnSelectorName;
        _reactHeroStepOnSelectorParam = theReactHeroStepOnSelectorParam;
        _reactWorldSelectorName = theReactWorldSelectorName;
        _reactWorldSelectorParam = theReactWorldSelectorParam;
        _reactTimeSelectorName = theReactTimeSelectorName;
        _reactionLasting = theReactionLasting;
        _reactTime = theReactTime;
        _cleanTime = theCleanTime;
        _triggerCleanHero = theTriggerCleanHero;
        _triggerCleanHeroStepOn = theTriggerCleanHeroStepOn;
        _triggerCleanWorld = theTriggerCleanWorld;
        _triggerCleanBoard = theTriggerCleanBoard;
    }
    
    return self;
}
@end
