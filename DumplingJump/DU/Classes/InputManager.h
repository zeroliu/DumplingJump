#import "GameLayer.h"

@interface InputManager : CCNode <UIGestureRecognizerDelegate>
+(id) sharedInputManager;
-(UISwipeGestureRecognizer *)watchForSwipeUp:(SEL)selector target:(id)theTarget number:(int)tapRequired;
@end
