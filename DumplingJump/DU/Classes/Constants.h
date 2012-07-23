#import "Common.h"

#define SENSIBILITY 1.0f
#define SPEED_INERTIA 0.8f
#define MAX_SPEED 5.0f

@interface Constants : NSObject
{
    float heroAccelerationXBase; //Define how fast the hero moves in X axis
}
@property (readonly, nonatomic) float heroAccelerationXBase;

+(id) shared;
@end
