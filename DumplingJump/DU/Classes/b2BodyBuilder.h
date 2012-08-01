#import "cocos2d.h"
#import "Box2D.h"

@interface b2BodyBuilder : NSObject
{
    b2World *world;
    BOOL fixedRotation;
    BOOL sleepingAllowed;
    b2BodyType type;
    b2FixtureDef fixtureDef;
    NSObject *userData;
}

-(id) initWithWorld:(b2World *)theWorld;

-(id) fixedRotation:(BOOL)value;
-(id) sleepingAllowed:(BOOL)value;
-(id) type:(b2BodyType)value;
-(id) fixture:(b2FixtureDef) value;
-(id) userData:(NSObject *) value;

-(b2Body *) build;
@end
