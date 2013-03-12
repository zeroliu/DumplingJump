//
//  ReactionManager.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-14.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//
#import "Reaction.h"
#import "ReactionManager.h"
#import "XMLHelper.h"

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
    self.reactionDictionary = [[XMLHelper shared] loadReactionWithXML:@"Editor_react"];
}

-(Reaction *) getReactionWithName:(NSString *)reactionName
{
    return [self.reactionDictionary objectForKey:reactionName];
}

-(NSString *) getReactionType:(NSString *)reactionName
{
    return ((Reaction *)[self.reactionDictionary objectForKey:reactionName]).type;
}

-(NSString *) getHeroReactAnimationName:(NSString *)reactionName
{
    return ((Reaction *)[self.reactionDictionary objectForKey:reactionName]).heroReactAnimationName;
}

@end
