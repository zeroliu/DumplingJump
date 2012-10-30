#import "AnimationManager.h"

@implementation AnimationManager

+(id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[AnimationManager alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
//        animDict = [[NSMutableDictionary alloc] init];
        [self loadAnimation];
    }
    
    return self;
}

-(void) loadAnimation
{
    //TODO: add from xml file
    [self addAnimationWithName:HEROIDLE file:@"HERO/AL_H_hero" startFrame:1 endFrame:10 delay:ANIMATION_DELAY_INBETWEEN];
    [self addAnimationWithName:HERODIZZY file:@"HERO/AL_H_dizzy" startFrame:1 endFrame:6 delay:ANIMATION_DELAY_INBETWEEN];
    [self addAnimationWithName:HEROHURT file:@"HERO/AL_H_hurt" startFrame:1 endFrame:1 delay:ANIMATION_DELAY_INBETWEEN];
    [self addAnimationWithName:HEROFLAT file:@"HERO/AL_H_flat" startFrame:1 endFrame:1 delay:ANIMATION_DELAY_INBETWEEN];
    [self addAnimationWithName:HEROFREEZE file:@"HERO/SK_H_ice" startFrame:1 endFrame:8 delay:ANIMATION_DELAY_INBETWEEN];
    [self addAnimationWithName:ANIM_EXPLOSION file:@"EFFECTS/AL_E_del" startFrame:1 endFrame:5 delay:ANIMATION_DELAY_INBETWEEN];
    [self addAnimationWithName:ANIM_ARROW_BREAK file:@"EFFECTS/CA_E_arrow" startFrame:1 endFrame:6 delay:ANIMATION_DELAY_INBETWEEN];
    [self addAnimationWithName:ANIM_ICE_EXPLODE file:@"EFFECTS/SK_E_frozen" startFrame:1 endFrame:6 delay:ANIMATION_DELAY_INBETWEEN];
    [self addAnimationWithName:ANIM_STAR file:@"ADDTHING/SK_star" startFrame:1 endFrame:7 delay:ANIMATION_DELAY_INBETWEEN];
    [self addAnimationWithName:ANIM_STONE_BREAK file:@"EFFECTS/CA_E_stone" startFrame:1 endFrame:4 delay:ANIMATION_DELAY_INBETWEEN];
    [self addAnimationWithName:ANIM_POWDER_EXPLODE file:@"EFFECTS/AL_E_powder" startFrame:1 endFrame:6 delay:ANIMATION_DELAY_INBETWEEN];
    
}

-(void) addAnimationWithName:(NSString *)theName file:(NSString *)theFile startFrame:(int)start endFrame:(int)end delay:(float)theDelay
{
    if ([[CCAnimationCache sharedAnimationCache] animationByName:theName] != nil)
    {
        DLog(@"Warning: Animation <%@> already existed.", theName);
        return;
    }
    
    NSMutableArray *frameArray = [NSMutableArray array];
    for (int i=start; i<=end; i++)
    {
        NSString *frameName = [NSString stringWithFormat:@"%@_%d.png",theFile,i];
        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [frameArray addObject:frameObject];
    }

    id animObject = [CCAnimation animationWithSpriteFrames :frameArray delay:theDelay];
//    id animAction = [CCAnimate actionWithAnimation:animObject restoreOriginalFrame:NO];
//    [animDict setObject:animAction forKey:theName];
    [[CCAnimationCache sharedAnimationCache] addAnimation:animObject name:theName];
}

-(id) getAnimationWithName:(NSString *)theName
{
//    return [self getAnimationWithName:theName repeat:0];
    return [[CCAnimationCache sharedAnimationCache] animationByName:theName];
}

/*
-(id) getAnimationWithName:(NSString *)theName repeat:(int)repeatTimes
{
    id animAction = [[animDict objectForKey:theName] copy];
    if (animAction == nil)
    {
        DLog(@"Warning: Animation <%@> can not be found", theName);
        [animAction release];
        return nil;
    }
    
    if (repeatTimes == 0)
    {
        animAction = [CCRepeatForever actionWithAction:animAction];
    } else if (repeatTimes > 0) {
        animAction = [CCRepeat actionWithAction:animAction times:repeatTimes];
    }
    return animAction;
}
 */

@end
