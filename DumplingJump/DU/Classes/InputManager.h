#import "cocos2d.h"

@interface InputManager : CCNode <UIGestureRecognizerDelegate> 
+(id) sharedInputManager;
-(UISwipeGestureRecognizer *)watchForSwipeWithDirection:(UISwipeGestureRecognizerDirection)theDirection selector:(SEL)theSelector target:(id)theTarget number:(int)tapRequired;
@end
