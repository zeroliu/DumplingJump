#import "DUSprite.h"

@implementation DUSprite
@synthesize sprite, animDict;

-(id) initWithName:(NSString *)theName sprite:(CCSprite *)theSprite
{
    if (self = [super initWithName:theName])
    {
        sprite = theSprite;
//        animDict = [NSMutableDictionary dictionary];
    }
    
    return self;
}

-(void) archive
{
    sprite.visible = NO;
    
    [super archive];
}

//-(void) addAnimationWithName:(NSString *)theName file:(NSString *)theFile startFrame:(int)start endFrame:(int)end delay:(float)theDelay repeat:(BOOL)canRepeat
//{
//    NSMutableArray *frameArray = [NSMutableArray array];
//    for (int i=start; i<=end; i++)
//    {
//        NSString *frameName = [NSString stringWithFormat:@"%@_%d.png",theFile,i];
//        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
//        [frameArray addObject:frameObject];
//    }
//
//    id animObject = [CCAnimation animationWithFrames:frameArray delay:theDelay];
//    id animAction = [CCAnimate actionWithAnimation:animObject restoreOriginalFrame:NO];
//    if(canRepeat)
//    {
//        animAction = [CCRepeatForever actionWithAction:animAction];
//    }
//
//    [animDict setObject:animAction forKey:theName];
//}

@end
