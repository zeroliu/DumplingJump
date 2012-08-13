#import "Common.h"

#pragma mark -
#pragma mark Constants
#define SENSIBILITY 1.0f
#define SPEED_INERTIA 0.8f
#define MAX_SPEED 5.0f

#pragma mark -
#pragma mark Physics
#define WORLD [[PhysicsManager sharedPhysicsManager] getWorld]
#define GROUND [[PhysicsManager sharedPhysicsManager] getGround]

#pragma mark -
#pragma mark Shared Managers
#define PHYSICSMANAGER [PhysicsManager sharedPhysicsManager]
#define ANIMATIONMANAGER [AnimationManager shared]
#define GAMEMANAGER [GameManager shared]

#pragma mark -
#pragma mark Signals
#define GAMELAYER_INITIALIZED @"GameLayerInitialized"
#define DISTANCEUPDATED @"distanceUpdated"

#pragma mark -
#pragma mark Backgrounds
#define SKY @"sheetBackground1"

#pragma mark -
#pragma mark Game states
#define GAME_INIT 0
#define GAME_READY 1
#define GAME_START 2

#pragma mark -
#pragma mark Level names
#define LEVEL_NORMAL @"normal"

#pragma mark -
#pragma mark Board filenames
#define SKY_BOARD @"PLATE/SK_plate.png"

#pragma mark -
#pragma mark Shapes
#define CIRCLE @"Circle"
#define BOX @"Box"

#pragma mark -
#pragma mark Addthings
#define TUB @"TUB"
#define VAT @"VAT"

#pragma mark -
#pragma mark Others
#define MESSAGECENTER [NSNotificationCenter defaultCenter]
#define BATCHNODE [[[Hub shared] gameLayer] batchNode]

@interface Constants : NSObject

@property (assign, nonatomic) float heroAccelerationXBase;

+(id) shared;
@end
