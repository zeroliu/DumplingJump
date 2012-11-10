#import "Common.h"

#pragma mark -
#pragma mark Constants
#define SENSIBILITY 1.56f
#define SPEED_INERTIA 0.8f
#define MAX_SPEED 3.125f
#define ANIMATION_DELAY_INBETWEEN 0.1f
#define SLOTS_NUM 9
#define DISTANCE_UNIT 0.015
#define SCALE_MULTIPLIER 1.33f
#define MASS_MULTIPLIER 9.8f
#define SHOCK_PRESSURE 200000

#pragma mark -
#pragma mark Physics
#define WORLD [[PhysicsManager sharedPhysicsManager] getWorld]
#define GROUND [[PhysicsManager sharedPhysicsManager] getGround]

#pragma mark -
#pragma mark Shared Managers
#define PHYSICSMANAGER [PhysicsManager sharedPhysicsManager]
#define ANIMATIONMANAGER [AnimationManager shared]
#define GAMEMANAGER [GameManager shared]
#define REACTIONFUNCTIONS [ReactionFunctions shared]

#pragma mark -
#pragma mark Signals
#define HEROONBOARD @"heroOnBoard"

#pragma mark -
#pragma mark Backgrounds
#define MAZE @"sheetBackground1"

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
#define SKY_BOARD @"SK_plate.png"
#define MAZE_BOARD @"CA_plate.png"

#pragma mark -
#pragma mark Shapes
#define CIRCLE @"Circle"
#define BOX @"Box"

#pragma mark -
#pragma mark Addthings
#define NOTHING @"Nothing"
#define HERO @"Hero"
#define BOARD @"Board"
#define TUB @"TUB"
#define VAT @"VAT"
#define BOMB @"Bomb"
#define ARROW @"Arrow"
#define STAR @"Star"
#define ICE @"ice"

#pragma mark -
#pragma mark Effects
#define FX_EXPLOSION @"FX_Explosion"
#define FX_ARROW_BREAK @"FX_ArrowBreak"
#define FX_FRONZEN @"FX_Frozen"
#define FX_STONEBREAK @"FX_StoneBreak"
#define FX_POWDER @"FX_Powder"
#define FX_BOW @"FX_Bow"
#define FX_DEL @"FX_Del"

#pragma mark -
#pragma mark Hero animations/Hero state
#define HEROIDLE @"AL_H_hero"
#define HERODIZZY @"AL_H_dizzy"
#define HEROHURT @"AL_H_hurt"
#define HEROFLAT @"AL_H_flat"
#define HEROFREEZE @"SK_H_ice"

#pragma mark -
#pragma mark Other animations
#define ANIM_EXPLOSION @"AL_E_del"
#define ANIM_ARROW_BREAK @"CA_E_arrow"
#define ANIM_STAR @"SK_star"
#define ANIM_ICE_EXPLODE @"SK_E_frozen"
#define ANIM_STONE_BREAK @"CA_E_stone"
#define ANIM_POWDER_EXPLODE @"AL_E_powder"
#define ANIM_BOW @"CA_E_bomb"

#pragma mark -
#pragma mark Others
#define MESSAGECENTER [NSNotificationCenter defaultCenter]
#define BATCHNODE [[[Hub shared] gameLayer] batchNode]
#define GAMELAYER [[Hub shared] gameLayer]
#define HEROMANAGER [HeroManager shared]
#define EFFECTMANAGER [EffectManager shared]

@interface Constants : NSObject

@property (assign, nonatomic) float heroAccelerationXBase;

+(id) shared;
@end
