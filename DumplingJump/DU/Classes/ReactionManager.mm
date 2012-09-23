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
    Reaction *reaction1 = [[Reaction alloc] initWithName:@"arrow" heroReactAnimationName:HERODIZZY effectName:FX_EXPLOSION reactHeroSelectorName:@"dizzy" reactHeroSelectorParam:nil reactHeroStepOnSelectorName:@"stepOn" reactHeroStepOnSelectorParam:nil reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:@"testFunction" reactionLasting:-1 reactTime:2 cleanTime:1 triggerCleanHero:-1 triggerCleanHeroStepOn:1 triggerCleanWorld:1 triggerCleanBoard:-1];
    Reaction *reaction2 = [[Reaction alloc] initWithName:@"bomb" heroReactAnimationName:@"hurt" effectName:@"explosion" reactHeroSelectorName:nil reactHeroSelectorParam:nil reactHeroStepOnSelectorName:nil reactHeroStepOnSelectorParam:nil reactWorldSelectorName:nil reactWorldSelectorParam:nil reactTimeSelectorName:@"explode" reactionLasting:-1 reactTime:5 cleanTime:5 triggerCleanHero:0 triggerCleanHeroStepOn:0 triggerCleanWorld:0 triggerCleanBoard:-1];
    [tmp setObject:reaction1 forKey:[reaction1 name]];
    [tmp setObject:reaction2 forKey:[reaction2 name]];
    
    self.reactionDictionary = [NSDictionary dictionaryWithDictionary:tmp];
}

-(Reaction *) getReactionWithName:(NSString *)reactionName
{
    return [self.reactionDictionary objectForKey:reactionName];
}

@end
