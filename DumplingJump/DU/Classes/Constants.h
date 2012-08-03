#import "Common.h"

#define SENSIBILITY 1.0f
#define SPEED_INERTIA 0.8f
#define MAX_SPEED 5.0f

#define PHYSICSMANAGER [PhysicsManager sharedPhysicsManager]
#define WORLD [[PhysicsManager sharedPhysicsManager] getWorld]
#define GROUND [[PhysicsManager sharedPhysicsManager] getGround]
#define ANIMATIONMANAGER [AnimationManager shared]
#define SCOREMANAGER [ScoreManager shared]
#define DUGAMEMANAGER [DUGameManager shared]
#define DUGAMEMODEL [DUGameModel shared]
#define MESSAGECENTER [NSNotificationCenter defaultCenter]

#define DISTANCEUPDATED @"distanceUpdated"

@interface Constants : NSObject
{
    float heroAccelerationXBase; //Define how fast the hero moves in X axis
}
@property (readonly, nonatomic) float heroAccelerationXBase;

+(id) shared;
@end
