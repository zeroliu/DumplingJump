#import "GameLayer.h"

@interface InputManager : CCNode <UIGestureRecognizerDelegate> 
+(id) sharedInputManager;
-(UISwipeGestureRecognizer *)watchForSwipeWithDirection:(UISwipeGestureRecognizerDirection)theDirection selector:(SEL)theSelector target:(id)theTarget number:(int)tapRequired;
-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
@end
