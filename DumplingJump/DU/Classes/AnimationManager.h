#import "Common.h"

@interface AnimationManager : CCNode
{
//    NSMutableDictionary *animDict;
}

+(id) shared;
//-(void) addAnimationWithName:(NSString *)theName file:(NSString *)theFile startFrame:(int)start endFrame:(int)end delay:(float)theDelay;
//-(void) removeAnimationWithName:(NSString *)theName;
-(id) getAnimationWithName:(NSString *)theName; //Repeat forever
//-(id) getAnimationWithName:(NSString *)theName repeat:(int)repeatTimes;
@end
