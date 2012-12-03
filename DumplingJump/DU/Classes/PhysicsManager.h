#import "Common.h"
#import "DUPhysicsObject.h"
#import "DUContactListener.h"
#define RATIO 32

@interface PhysicsManager : CCNode
{
    b2World *world;
    b2Body *ground;
}

@property (nonatomic, assign) float mass_multiplier;

+(id) sharedPhysicsManager;
-(b2World *) getWorld;
-(b2Body *) getGround;
-(void) addToArchiveList:(DUPhysicsObject *)physicsObject;
-(void) addToDisactiveList:(DUPhysicsObject *)physicsObject;
-(void) updatePhysicsBody:(ccTime)dt;
-(void) setCustomGravity:(float)newGravity;

@end
