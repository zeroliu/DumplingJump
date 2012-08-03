#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "Hub.h"
#import "Box2D.h"
#import "Constants.h"

#import "PhysicsManager.h"
#import "InputManager.h"
#import "AccelerometerManager.h"
#import "AnimationManager.h"
#import "ScoreManager.h"
#import "DUGameModel.h"
#import "DUGameManager.h"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define SAE [SimpleAudioEngine sharedEngine]

float randomFloat(float start, float end);
int randomInt(int start, int end);

