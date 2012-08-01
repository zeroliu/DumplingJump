#import "b2FixtureDefBuilder.h"

@implementation b2FixtureDefBuilder

-(id) init
{
    if (self = [super init])
    {
        density = 0;
        friction = 0;
        restitution = 0;
    }
    
    return self;
}

-(id) boxShapeWithWidth:(float)width height:(float)height
{
    b2PolygonShape _shape;
    _shape.SetAsBox(width, height);
    shape = _shape;
    return self;
}

-(id) circleShape:(float)radius
{
    b2CircleShape _shape;
    _shape.m_radius = radius;
    shape = _shape;
    return self;
}

-(id) density:(float)theDensity
{
    density = theDensity;
    return self;
}

-(id) friction:(float)theFriction
{
    friction = theFriction;
    return self;
}

-(id) restitution:(float)theRestitution
{
    restitution = theRestitution;
    return self;
}

-(b2FixtureDef) build
{
    b2FixtureDef fixtureDef;
    
    fixtureDef.shape = &shape;
    fixtureDef.density = density;
    fixtureDef.friction = friction;
    fixtureDef.restitution = restitution;
    
    return fixtureDef;
}

@end
