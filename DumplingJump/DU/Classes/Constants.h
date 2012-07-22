#import "Common.h"

@interface Constants : NSObject
{
    float heroAccelerationXBase; //Define how fast the hero moves in X axis
}
@property (readonly, nonatomic) float heroAccelerationXBase;

+(id) shared;
@end
