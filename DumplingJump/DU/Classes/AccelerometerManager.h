#import "cocos2d.h"

@interface AccelerometerManager : CCNode <UIAccelerometerDelegate>
{
//    NSMutableArray *accelerationListeners;
//    AccelerometerListener *currentListener;
    float accX;
    float accY;
    float accZ;
}
@property (readonly, atomic) float accX;
@property (readonly, atomic) float accY;
@property (readonly, atomic) float accZ;

+(id) shared;
//-(AccelerometerListener *) watchAccelerometer:(SEL)theSelector target:(id)theTarget;

@end
