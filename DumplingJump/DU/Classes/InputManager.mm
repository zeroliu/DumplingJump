#import "InputManager.h"

@implementation InputManager

+(id) sharedInputManager
{
    static id sharedInputManager = nil;
    if (sharedInputManager == nil) 
    {
        sharedInputManager = [[InputManager alloc] init];
    }
    return sharedInputManager;
}

-(UISwipeGestureRecognizer *)watchForSwipeWithDirection:(UISwipeGestureRecognizerDirection)theDirection selector:(SEL)theSelector target:(id)theTarget number:(int)tapRequired
{
    UISwipeGestureRecognizer *recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:theTarget action:theSelector] autorelease];
    recognizer.numberOfTouchesRequired = tapRequired;
    recognizer.direction = theDirection;
    
    [[[CCDirector sharedDirector] view] addGestureRecognizer:recognizer];
    return recognizer;
}

-(void)unWatch:(UIGestureRecognizer *)recognizer
{
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:recognizer];
}

@end
