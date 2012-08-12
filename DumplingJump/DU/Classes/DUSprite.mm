#import "DUSprite.h"

@implementation DUSprite
@synthesize sprite = _sprite;

-(id) initWithName:(NSString *)theName file:(NSString *)fileName;
{
    if (self = [super initWithName:theName])
    {
        self.sprite = [CCSprite spriteWithSpriteFrameName:fileName];
    }
    
    return self;
}

-(void) addChildTo: (CCNode *)node
{
    [self addChildTo:node z:0];
}

-(void) addChildTo:(CCNode *)node z:(int)zLayer
{
    if (!self.rebuilt) [node addChild:self.sprite z:zLayer];
}

-(void) activate
{
    [super activate];
    self.sprite.visible = YES;
}

-(void) deactivate
{
    [super deactivate];
    self.sprite.visible = NO;
    self.sprite.position = ccp(-0,-0);
    [self.sprite stopAllActions];
//    [sprite removeFromParentAndCleanup:NO];
//    NSLog(@"call DUSpirte deactive");
}

-(void) archive
{
    [super archive];
}

-(void) dealloc
{
    [self.sprite removeFromParentAndCleanup:YES];
    [self.sprite release];
    [super dealloc];
}
@end
