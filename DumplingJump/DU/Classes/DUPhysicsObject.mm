#import "DUPhysicsObject.h"
#define RATIO 32

@implementation DUPhysicsObject
@synthesize body = _body;

-(id) initWithName:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody
{
    if (self = [super initWithName:theName file:theFile])
    {
        self.body = theBody;
        self.sprite = [CCSprite spriteWithSpriteFrameName:theFile];
        self.body->SetUserData(self);
    }
    
    return self;
}

-(void) setUserData:(id)data;
{
    self.body->SetUserData(data);
}

-(void) resetPhysicsBodyPosition
{
    self.body->SetTransform(*new b2Vec2(self.sprite.position.x/RATIO, self.sprite.position.y/RATIO),0);
}

-(void) addChildTo: (CCNode *)node z:(int)zLayer
{
    [self resetPhysicsBodyPosition];
    [super addChildTo:node z:zLayer];
}

-(void) activate
{
    [super activate];
    self.body->SetActive(true);
    self.body->SetAwake(true);
    //TODO: Add info for contacts
}

-(void) deactivate
{
    [super deactivate];
    self.body->SetActive(false);
    self.body->SetAwake(false);
    self.body->SetTransform(*new b2Vec2(0, 0),0);
    self.body->SetLinearVelocity(*new b2Vec2(0,0));
    self.body->SetAngularVelocity(0);
    //TODO: Add info for contacts
//    NSLog(@"call DUPhysics deactive");
}

-(void) archive
{
    [super archive];
}

-(void) dealloc
{
    self.body->GetWorld()->DestroyBody(self.body);
    [super dealloc];
}

@end
