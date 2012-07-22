#import "Constants.h"

@implementation Constants
@synthesize heroAccelerationXBase;
+(id) shared
{
    static id shared = nil;
    if(shared == nil)
    {
        shared = [[Constants alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        heroAccelerationXBase = 0.1;
    }
    
    return self;
}
@end
