#define IS_WIDESCREEN ( fabs((double)[[UIScreen mainScreen] bounds ].size.height - (double)568)<DBL_EPSILON)
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define BLACK_HEIGHT (IS_WIDESCREEN ? 43 : 0)

#pragma mark -
#pragma mark Constants
#define SENSIBILITY 1.56f
#define SPEED_INERTIA 0.8f
#define MAX_SPEED 3.125f
#define ANIMATION_DELAY_INBETWEEN 0.1f
#define SLOTS_NUM 9
#define STAR_Y_INTERVAL 40
#define SCALE_MULTIPLIER 1.33f
#define MASS_MULTIPLIER 6.0f
#define SHOCK_PRESSURE 200000
#define GAMELAYER_TAG 1
#define GAMEUI_TAG 2

#pragma mark -
#pragma mark Layer Priority
#define Z_DEADUI 25
#define Z_PAUSEUI 25
#define Z_GAMEUI 22
#define Z_Speedline 20
#define Z_Hero 5
#define Z_Hero_Reborn 15

//game mask z order doesn't work because game mask sprite is not in sheetobject
#define Z_GAME_MASK 12
#define Z_Board 10
#define Z_Engine 11
#define Z_WarningSign 100

#pragma mark -
#pragma mark MainMenu Layer Priority
#define Z_BATCHNODE 10
#define Z_BUTTONS 3
#define Z_SECONDARY_UI 2
#define Z_MASK 1

#pragma mark -
#pragma mark Achievement Notification
#define NOTIFICATION_JUMP @"actionJump"
#define NOTIFICATION_DIE @"actionDie"
#define NOTIFICATION_SPRING @"powerSpring"
#define NOTIFICATION_MAGIC @"powerSword"
#define NOTIFICATION_BOOSTER @"powerBoost"
#define NOTIFICATION_REBORN @"itemReborn"
#define NOTIFICATION_SHIELD @"skillShield"
#define NOTIFICATION_MAGNET @"skillMagnet"
#define NOTIFICATION_HEADSTART @"itemHeadStart"
#define NOTIFICATION_STAR @"star"
#define NOTIFICATION_DISTANCE @"distance"
#define NOTIFICATION_SCORE @"score"
#define NOTIFICATION_MEGASTAR @"powerMega"
#define NOTIFICATION_LIFE_DIE @"lifeDie"
#define NOTIFICATION_LIFE_GAME @"lifeGames"
#define NOTIFICATION_LIFE_JUMP @"lifeJump"
#define NOTIFICATION_LIFE_DISTANCE @"lifeDistance"
#define NOTIFICATION_LIFE_STAR @"lifeStars"
#define NOTIFICATION_POWER_COLLECT @"powerCollect"
#define NOTIFICATION_POWERUP_LEVEL @"powerLevel"
#define NOTIFICATION_SKILL_LEVEL @"skillLevel"
#define NOTIFICATION_BOOSTER_UNDER @"actionBoosterUnder"
#define NOTIFICATION_DIE_TIME @"actionDie"


#pragma mark -
#pragma mark TAG
#define TAG_SPRING_BOOST 999
#define TAG_HEADSTART_BOOST 998
#define TAG_HEADSTART_TRAIL 997
#define TAG_HEADSTART_SUPPORT 996
#define TAG_BREAK_ICE_HINT 995


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
#define MAZE_BOARD @"O_plate.png"

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
#define FX_ItemBomb @"FX_ItemBomb"
#define FX_DEL @"FX_Del"

#pragma mark -
#pragma mark Hero animations/Hero state
#define HEROIDLE @"H_hero"
#define HEROREBORN @"H_heroReborn"
#define SPRINGJUMP @"H_spring_jump"
#define HEROSPRING @"H_spring"
#define SPRINGBOOSTEFFECT @"E_item_spring"
#define HEADSTART_BOOST @"E_item_headstart_wave"
#define HEADSTART_TRAIL @"E_item_headstart_trail"
#define HEADSTART_SUPPORT @"O_headstart"

#pragma mark -
#pragma mark Other animations
#define ANIM_BROOM @"O_engine"
#define ANIM_BROOM_BROKEN @"O_engine_broken"
#define ANIM_BROOM_RECOVER @"O_engine_recover"

#pragma mark -
#pragma mark Collision Layers
#define C_NOTHING 0x0000
#define C_HERO 0x0001
#define C_BOARD 0x0002
#define C_ADDTHING 0x0004
#define C_SLASH 0x0008
#define C_STAR 0x0010
#define C_ABSORB 0x0020
#define C_HEAD 0x0040
#define EVERYTHING C_SLASH | C_HERO | C_BOARD | C_ADDTHING | C_STAR

#pragma mark -
#pragma mark Others
#define MESSAGECENTER [NSNotificationCenter defaultCenter]
#define BATCHNODE [[[Hub shared] gameLayer] batchNode]
#define GAMELAYER [[Hub shared] gameLayer]
#define HEROMANAGER [HeroManager shared]
#define EFFECTMANAGER [EffectManager shared]
#define POWERUP_DATA ((GameLayer *) GAMELAYER).model.powerUpData
#define GAMEMODEL ((GameModel *)((GameLayer *) GAMELAYER).model)
#define VIEW [[CCDirector sharedDirector] view]
#define USERDATA ((UserData *)[UserData shared]).userDataDictionary
@interface Constants : NSObject

@property (assign, nonatomic) float heroAccelerationXBase;

+(id) shared;
@end
