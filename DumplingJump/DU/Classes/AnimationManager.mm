#import "AnimationManager.h"

@interface AnimationManager()
@property (nonatomic, retain) NSMutableDictionary *animDataDictionary;
@end

@implementation AnimationManager
@synthesize animDataDictionary = _animDataDictionary;

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
        [self loadAnimationData];
        
    }
    
    return self;
}

-(void) loadAnimationData
{
    NSString *path;
    if (CC_CONTENT_SCALE_FACTOR() == 2)
    {
        path = [[NSBundle mainBundle] pathForResource:@"sheetObjects-hd" ofType:@"plist"];
    } else
    {
        path = [[NSBundle mainBundle] pathForResource:@"sheetObjects" ofType:@"plist"];
    }
    
    _animDataDictionary = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] objectForKey:@"frames"];
}

-(void) registerAnimationForName:(NSString *)theName
{
    [self registerAnimationForName:theName speed:1];
}

-(void) registerAnimationForName:(NSString *)theName speed:(float)theSpeed
{
    if ([[CCAnimationCache sharedAnimationCache] animationByName:theName] != nil)
    {
        DLog(@"Warning: Animation <%@> already existed.", theName);
        return;
    }
    
    int count = 1;
    while ([self.animDataDictionary objectForKey:[NSString stringWithFormat:@"%@_%d.png", theName, count]] != nil)
    {
        count ++;
    }
    
    [self addAnimationWithName:theName file:theName startFrame:1 endFrame:(count-1) delay:ANIMATION_DELAY_INBETWEEN/theSpeed];
//    DLog(@"Animation %@ registed", theName);
}

-(void) addAnimationWithName:(NSString *)theName file:(NSString *)theFile startFrame:(int)start endFrame:(int)end delay:(float)theDelay
{
    if ([[CCAnimationCache sharedAnimationCache] animationByName:theName] != nil)
    {
        DLog(@"Warning: Animation <%@> already existed.", theName);
        return;
    }
    
    NSMutableArray *frameArray = [[NSMutableArray alloc] initWithCapacity:(end-start+1)];
    for (int i=start; i<=end; i++)
    {
        NSAssert([theName isEqualToString:theFile], [NSString stringWithFormat: @"something wrong with the animation name"]);
        
        NSString *frameName = [NSString stringWithFormat:@"%@_%d.png",theFile,i];
        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [frameArray addObject:frameObject];
    }

    id animObject = [CCAnimation animationWithSpriteFrames :frameArray delay:theDelay];
    [[CCAnimationCache sharedAnimationCache] addAnimation:animObject name:theName];
    [frameArray release];
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
- (void)dealloc
{
    [_animDataDictionary release];
    [super dealloc];
}
@end
