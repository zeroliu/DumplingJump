#import "cocos2d.h"

@interface AccelerometerManager : CCNode <UIAccelerometerDelegate>

@property (assign, atomic) float accX;
@property (assign, atomic) float accY;
@property (assign, atomic) float accZ;

+(id) shared;
//-(AccelerometerListener *) watchAccelerometer:(SEL)theSelector target:(id)theTarget;

@end
