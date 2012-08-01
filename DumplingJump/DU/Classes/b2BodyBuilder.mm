#import "b2BodyBuilder.h"

@implementation b2BodyBuilder

-(id) initWithWorld:(b2World *)theWorld
{
    if (self = [super init])
    {
        world = theWorld;
        fixedRotation = false;
        sleepingAllowed = true;
        type = b2_dynamicBody;
//        fixtureDef = NULL;
    }
    
    return self;
}

-(id) fixedRotation:(BOOL)value
{
    fixedRotation = value;
    return self;
}

-(id) sleepingAllowed:(BOOL)value
{
    sleepingAllowed = value;
    return self;
}

-(id) type:(b2BodyType)value
{
    type = value;
    return self;
}

-(id) fixture:(b2FixtureDef) value
{
    fixtureDef = value;
    return self;
}

-(id) userData:(NSObject *) value
{
    userData = value;
    return self;
}

-(b2Body *) build
{
    b2BodyDef bodyDef;
    bodyDef.type = type;
    b2Body *body = world->CreateBody(&bodyDef);
    body->CreateFixture(&fixtureDef);
//    body->SetType(type);
    body->SetSleepingAllowed(sleepingAllowed);
    body->SetFixedRotation(fixedRotation);
    if (userData) body->SetUserData(userData);
    
    return body;
}
@end
