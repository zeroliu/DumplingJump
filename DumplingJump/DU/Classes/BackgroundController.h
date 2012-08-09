#import "Common.h"
#import "BackgroundModel.h"
#import "BackgroundView.h"

@interface BackgroundController : CCNode

-(void) setBackgroundWithName:(NSString *)bgName;
-(void) updateBackground:(ccTime)deltaTime;
@end
