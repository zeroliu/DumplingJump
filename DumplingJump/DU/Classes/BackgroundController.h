#import "Common.h"
#import "BackgroundModel.h"
#import "BackgroundView.h"

@interface BackgroundController : CCNode

+(id) shared;
-(void) setBackgroundWithName:(NSString *)bgName;
-(void) updateBackground:(ccTime)deltaTime;
-(void) speedUpWithScale:(int)scale interval:(float)time;
-(void) initParam;
@end
