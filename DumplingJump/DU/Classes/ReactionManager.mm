//
//  ReactionManager.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-14.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "ReactionManager.h"


@interface ReactionManager()

@property (nonatomic,retain) NSDictionary *reactionDictionary;

@end

@implementation ReactionManager
@synthesize reactionDictionary = _reactionDictionary;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[ReactionManager alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        [self loadReactions];
    }
    
    return self;
}

-(void) loadReactions
{
    NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
    Reaction *reaction1 = [[Reaction alloc] initWithName:@"arrow" heroReactAnimationName:HEROHURT effectName:FX_ARROW_BREAK reactHeroSelectorName:@"hurt" reactHeroSelectorParam:@"25" reactHeroStepOnSelectorName:@"hurt" reactHeroStepOnSelectorParam:@"25" reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:nil reactionLasting:0.5f reactTime:-1 cleanTime:-1 triggerCleanHero:1 triggerCleanHeroStepOn:1 triggerCleanWorld:1 triggerCleanBoard:1];
    Reaction *reaction2 = [[Reaction alloc] initWithName:@"flat" heroReactAnimationName:HEROFLAT effectName:FX_STONEBREAK reactHeroSelectorName:@"flat" reactHeroSelectorParam:nil reactHeroStepOnSelectorName:nil reactHeroStepOnSelectorParam:nil reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:nil reactionLasting:4 reactTime:-1 cleanTime:-1 triggerCleanHero:1 triggerCleanHeroStepOn:1 triggerCleanWorld:1 triggerCleanBoard:1];
    Reaction *reaction3 = [[Reaction alloc] initWithName:@"powder" heroReactAnimationName:nil effectName:FX_POWDER reactHeroSelectorName:nil reactHeroSelectorParam:nil reactHeroStepOnSelectorName:nil reactHeroStepOnSelectorParam:nil reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:@"explode" reactionLasting:2 reactTime:3.5f cleanTime:3.5f triggerCleanHero:-1 triggerCleanHeroStepOn:-1 triggerCleanWorld:-1 triggerCleanBoard:-1];
    Reaction *reaction4 = [[Reaction alloc] initWithName:@"powder_l" heroReactAnimationName:nil effectName:FX_POWDER reactHeroSelectorName:nil reactHeroSelectorParam:nil reactHeroStepOnSelectorName:nil reactHeroStepOnSelectorParam:nil reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:@"explode_l" reactionLasting:2 reactTime:3.5f cleanTime:3.5f triggerCleanHero:-1 triggerCleanHeroStepOn:-1 triggerCleanWorld:-1 triggerCleanBoard:-1];
    Reaction *reaction5 = [[Reaction alloc] initWithName:@"powder_r" heroReactAnimationName:nil effectName:FX_POWDER reactHeroSelectorName:nil reactHeroSelectorParam:nil reactHeroStepOnSelectorName:nil reactHeroStepOnSelectorParam:nil reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:@"explode_r" reactionLasting:2 reactTime:3.5f cleanTime:3.5f triggerCleanHero:-1 triggerCleanHeroStepOn:-1 triggerCleanWorld:-1 triggerCleanBoard:-1];
    Reaction *reaction6 = [[Reaction alloc] initWithName:@"bow" heroReactAnimationName:HEROHURT effectName:FX_BOW reactHeroSelectorName:nil reactHeroSelectorParam:nil reactHeroStepOnSelectorName:nil reactHeroStepOnSelectorParam:nil reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:@"bow" reactionLasting:1.0f reactTime:2.5f cleanTime:2.5f triggerCleanHero:-1 triggerCleanHeroStepOn:-1 triggerCleanWorld:-1 triggerCleanBoard:-1];
    [tmp setObject:reaction1 forKey:[reaction1 name]];
    [tmp setObject:reaction2 forKey:[reaction2 name]];
    [tmp setObject:reaction3 forKey:[reaction3 name]];
    [tmp setObject:reaction4 forKey:[reaction4 name]];
    [tmp setObject:reaction5 forKey:[reaction5 name]];
    [tmp setObject:reaction6 forKey:[reaction6 name]];
    self.reactionDictionary = [NSDictionary dictionaryWithDictionary:tmp];
}

-(Reaction *) getReactionWithName:(NSString *)reactionName
{
    return [self.reactionDictionary objectForKey:reactionName];
}

@end
