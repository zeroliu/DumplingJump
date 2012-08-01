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

-(void) setUserData:(id)data;
{
    body->SetUserData(data);
}

-(void) resetPhysicsBodyPosition
{
    body->SetTransform(*new b2Vec2(sprite.position.x/RATIO, sprite.position.y/RATIO),0);
}

-(void) addChildTo: (CCNode *)node z:(int)zLayer
{
    [self resetPhysicsBodyPosition];
    [super addChildTo:node z:zLayer];
}

-(void) activate
{
    [super activate];
    body->SetActive(true);
    body->SetAwake(true);
    //TODO: Add info for contacts
}

-(void) deactivate
{
    [super deactivate];
    body->SetActive(false);
    body->SetAwake(false);
    body->SetTransform(*new b2Vec2(0, 0),0);
    body->SetLinearVelocity(*new b2Vec2(0,0));
    body->SetAngularVelocity(0);
    //TODO: Add info for contacts
//    NSLog(@"call DUPhysics deactive");
}

-(void) archive
{
    [super archive];
}

-(void) dealloc
{
    body->GetWorld()->DestroyBody(body);
    [super dealloc];
}

@end
