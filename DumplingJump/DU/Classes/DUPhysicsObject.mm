#import "DUPhysicsObject.h"
#define RATIO 32

@implementation DUPhysicsObject

-(id) initWithName:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody
{
    if (self = [super initWithName:theName file:theFile])
    {
        body = theBody;
        sprite = [CCSprite spriteWithSpriteFrameName:theFile];
        body->SetUserData(self);
    }
    
    return self;
}

-(void) activate
{
    body->SetActive(true);
    body->SetAwake(true);
    [self resetPhysicsBody];
}

-(void) deactivate
{
    body->SetActive(false);
    body->SetAwake(false);
    body->SetTransform(*new b2Vec2(0, 0),0);
    body->SetLinearVelocity(*new b2Vec2(0,0));
    body->SetAngularVelocity(0);
}

-(void) resetPhysicsBody
{
    body->SetTransform(*new b2Vec2(sprite.position.x/RATIO, sprite.position.y/RATIO),0);
}

-(BOOL) addChildTo: (CCNode *)node
{
    [self resetPhysicsBody];
    return [super addChildTo:node];
}

-(void) archive
{
    [super archive];
    [self deactivate];
}

@end
