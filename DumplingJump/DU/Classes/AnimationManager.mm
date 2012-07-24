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
        animDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void) addAnimationWithName:(NSString *)theName file:(NSString *)theFile startFrame:(int)start endFrame:(int)end delay:(float)theDelay
{
    if ([animDict objectForKey:theName] != nil)
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

    id animObject = [CCAnimation animationWithFrames:frameArray delay:theDelay];
    id animAction = [CCAnimate actionWithAnimation:animObject restoreOriginalFrame:NO];
    
    [animDict setObject:animAction forKey:theName];
}

-(void) removeAnimationWithName:(NSString *)theName
{
    if ([animDict objectForKey:theName] == nil)
    {
        DLog(@"Warning: Animation <%@> does not exist. Remove can not be done", theName);
        return;
    }
    
    [animDict removeObjectForKey:theName];
}

-(id) getAnimationWithName:(NSString *)theName
{
    return [self getAnimationWithName:theName repeat:-1];
}

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
@end
