#import "cocos2d.h"
#import "Box2D.h"

@interface b2DisjointDefBuilder : NSObject
{
    b2World *world;
    
    b2Body *bodyA;
    b2Body *bodyB;
    
}

//-(id) initWithWorld:(b2World *) world;
//
//-(id) initializeWithBodyA:(b2Body *)theBodyA bodyB:(b2Body *)theBodyB anchorA:(b2Vec2)theAnchorA anchorB:(b2Vec2)theAnchorB;

//rocketDisJointDef_R.Initialize(ground, body, ground_R, anchor_R);
//rocketDisJointDef_R.collideConnected = true;
//rocketDisJointDef_R.frequencyHz = 1;
//rocketDisJointDef_R.dampingRatio = 1;
//world->CreateJoint(&rocketDisJointDef_R);
@end
