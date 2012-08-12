#import "HeroManager.h"

@implementation HeroManager
@synthesize hero = _hero;
#pragma mark -
#pragma Initialization

-(id)createHeroWithPosition:(CGPoint)thePosition
{
    if (self.hero != nil) [self.hero release];
    self.hero = [[Hero alloc] initHeroWithName:@"Hero" position:thePosition];
    [self.hero addChildTo:BATCHNODE];
    
    return self.hero;
}

-(void) updateHeroPosition
{
    if (self.hero == nil) return;
    [self.hero updateHeroPositionWithAccX:[[AccelerometerManager shared] accX]];
}

-(void) jump
{
    if (self.hero == nil) return;
    [self.hero jump];
}
@end
