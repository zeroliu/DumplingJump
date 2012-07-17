#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "Box2D.h"

#define SAE [SimpleAudioEngine sharedEngine]

//Pixel to Meter, for box2D unit transition
#define PTM_RATIO 32

float randomFloat(float start, float end);
int randomInt(int start, int end);

