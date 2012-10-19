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
    Reaction *reaction1 = [[Reaction alloc] initWithName:@"arrow" heroReactAnimationName:HEROHURT effectName:FX_ARROW_BREAK reactHeroSelectorName:@"hurt" reactHeroSelectorParam:@"25" reactHeroStepOnSelectorName:@"hurt" reactHeroStepOnSelectorParam:@"25" reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:nil reactionLasting:0 reactTime:-1 cleanTime:-1 triggerCleanHero:1 triggerCleanHeroStepOn:1 triggerCleanWorld:1 triggerCleanBoard:1];
    Reaction *reaction2 = [[Reaction alloc] initWithName:@"bomb" heroReactAnimationName:HEROHURT effectName:FX_EXPLOSION reactHeroSelectorName:nil reactHeroSelectorParam:nil reactHeroStepOnSelectorName:nil reactHeroStepOnSelectorParam:nil reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:@"explode" reactionLasting:0 reactTime:3 cleanTime:3 triggerCleanHero:-1 triggerCleanHeroStepOn:-1 triggerCleanWorld:-1 triggerCleanBoard:-1];
    Reaction *reaction3 = [[Reaction alloc] initWithName:@"ice" heroReactAnimationName:HEROFREEZE effectName:FX_FRONZEN reactHeroSelectorName:@"freeze" reactHeroSelectorParam:nil reactHeroStepOnSelectorName:nil reactHeroStepOnSelectorParam:nil reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:nil reactionLasting:3 reactTime:-1 cleanTime:-1 triggerCleanHero:1 triggerCleanHeroStepOn:1 triggerCleanWorld:1 triggerCleanBoard:0];
    [tmp setObject:reaction1 forKey:[reaction1 name]];
    [tmp setObject:reaction2 forKey:[reaction2 name]];
    [tmp setObject:reaction3 forKey:[reaction3 name]];
    
    self.reactionDictionary = [NSDictionary dictionaryWithDictionary:tmp];
}

-(Reaction *) getReactionWithName:(NSString *)reactionName
{
    return [self.reactionDictionary objectForKey:reactionName];
}

@end
