#import "Common.h"
#import "DUPhysicsObject.h"

#define RATIO 32

@interface PhysicsManager : CCNode
{
    b2World *world;
    b2Body *ground;
}

+(id) sharedPhysicsManager;
-(b2World *) getWorld;
-(b2Body *) getGround;
-(void) addToArchiveList:(DUPhysicsObject *)physicsObject;
-(void) updatePhysicsBody:(ccTime)dt;
@end
