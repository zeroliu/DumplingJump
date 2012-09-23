//
//  Reaction.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-13.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface Reaction : CCNode

@property (nonatomic, readonly)
NSString *name, //Reaction name
*heroReactAnimationName, //The animation needs to be played when touch hero
*effectName, //The animation needs to be played when taking effect
*reactHeroSelectorName, //The selector will be called if addthings touch hero(above hero)
*reactHeroSelectorParam, //The parameter of the previous selector
*reactHeroStepOnSelectorName, //The selector will be called if hero step on the addthings
*reactHeroStepOnSelectorParam, 
*reactWorldSelectorName, //The selector will be called if addthings touch anything else
*reactWorldSelectorParam,
*reactTimeSelectorName; //The selector will be called if time is up
@property (assign, readonly)
double reactionLasting, //How long does it last
reactTime, //How long does it take to trigger the reactTimeSelector
cleanTime; //How long does it take to make the addthing disappear by itself
@property (assign, readonly)
int triggerCleanHero, //1 => Addthing get removed after touch the hero. Any other numbers => nothing happens
triggerCleanHeroStepOn, //1 => Addthing get removed after hero steps on it
triggerCleanWorld,
triggerCleanBoard;

-(id) initWithName              :(NSString *)theName 
heroReactAnimationName          :(NSString *)theHeroReactAnimationName 
effectName             :(NSString *)theAnimationName 
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
triggerCleanWorld               :(int)
theTriggerCleanWorld
triggerCleanBoard               :(int) theTriggerCleanBoard;

@end
