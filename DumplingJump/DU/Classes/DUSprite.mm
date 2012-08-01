#import "DUSprite.h"

@implementation DUSprite
@synthesize sprite;

-(id) initWithName:(NSString *)theName file:(NSString *)fileName;
{
    if (self = [super initWithName:theName])
    {
        sprite = [CCSprite spriteWithSpriteFrameName:fileName];
    }
    
    return self;
}

-(void) addChildTo: (CCNode *)node
{
    [self addChildTo:node z:0];
}

-(void) addChildTo:(CCNode *)node z:(int)zLayer
{
    if (!rebuilt) [node addChild:sprite z:zLayer];
}

-(void) activate
{
    [super activate];
    sprite.visible = YES;
}

-(void) deactivate
{
    [super deactivate];
    sprite.visible = NO;
    sprite.position = ccp(-0,-0);
    [sprite stopAllActions];
//    [sprite removeFromParentAndCleanup:NO];
//    NSLog(@"call DUSpirte deactive");
}

-(void) archive
{
    [super archive];
}

-(void) dealloc
{
    [sprite release];
    [super dealloc];
}
@end
