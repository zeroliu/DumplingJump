#import "cocos2d.h"
#import "Box2D.h"

@interface b2FixtureDefBuilder : NSObject
{
    b2Shape shape;
    float density;
    float friction;
    float restitution;
}

-(id) init;
-(id) boxShapeWithWidth:(float)width height:(float)height;
-(id) circleShape:(float)radius;
-(id) density:(float)theDensity;
-(id) friction:(float)theFriction;
-(id) restitution:(float)theRestitution;
-(b2FixtureDef) build;
@end
