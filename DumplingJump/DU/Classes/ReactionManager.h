//
//  ReactionManager.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-14.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "CCNode.h"
#import "Reaction.h"
#import "Constants.h"

@interface ReactionManager : CCNode

+(id) shared;
-(Reaction *) getReactionWithName:(NSString *)reactionName;
-(NSString *) getReactionType:(NSString *)reactionName;
-(NSString *) getHeroReactAnimationName:(NSString *)reactionName;
@end
