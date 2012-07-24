#import "DUSprite.h"

@implementation DUSprite
@synthesize sprite;

-(id) initWithName:(NSString *)theName file:(NSString *)fileName;
{
    if (self = [super initWithName:theName])
    {
        sprite = [CCSprite spriteWithSpriteFrameName:fileName];
        rebuilt = NO;
    }
    
    return self;
}

-(BOOL) addChildTo: (CCNode *)node
{
    return [self addChildTo:node z:0];
}

-(BOOL) addChildTo:(CCNode *)node z:(int)zLayer
{
    if(rebuilt == YES)
    {
        return NO;
    } else {
        [node addChild:sprite z:zLayer];
        return YES;
    }
}

-(void) archive
{
    sprite.visible = NO;
    sprite.position = ccp(-0,-0);
    [sprite stopAllActions];
    [super archive];
}

-(void) dealloc
{
    [sprite release];
    [super dealloc];
}

@end
