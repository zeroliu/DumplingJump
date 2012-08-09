#import "AccelerometerManager.h"

@implementation AccelerometerManager
@synthesize accX = _accX, accY = _accY, accZ = _accZ;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[AccelerometerManager alloc] init];
    }
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
//        accelerationListeners = [NSMutableArray array];
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    }
    
    return self;
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    self.accX = acceleration.x;
    self.accY = acceleration.y;
    self.accZ = acceleration.z;
}

//-(void) dispatch:(UIAcceleration *)acceleration
//{
//    for (NSObject *listener in accelerationListeners)
//    {
//        currentListener = (AccelerometerListener *)listener;
//        [currentListener.target performSelector:currentListener.selector withObject:acceleration];
//    }
//}

//-(AccelerometerListener *)watchAccelerometer:(SEL)theSelector target:(id)theTarget
//{
//    AccelerometerListener *listener = [[[AccelerometerListener alloc] initWithTarget:self selector:@selector(onAccelerometerUpdate:)]autorelease];
//    [self addListener:listener];
//    return listener;
//}
//
//-(void) addListener:(AccelerometerListener *)listener
//{
//    [accelerationListeners addObject:listener];
//}
//
//-(void) removeListener:(AccelerometerListener *)listener
//{
//    [accelerationListeners removeObject:listener];
//}
//
//-(void) dealloc
//{
//    [accelerationListeners release];
//    [super dealloc];
//}

@end
