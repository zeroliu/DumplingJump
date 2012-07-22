//
//  InputManager.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-7-20.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

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

-(id) init
{
    if (self = [super init])
    {
        
    }
    return self;
}

-(UISwipeGestureRecognizer *)watchForSwipeWithDirection:(UISwipeGestureRecognizerDirection)theDirection selector:(SEL)theSelector target:(id)theTarget number:(int)tapRequired
{
    UISwipeGestureRecognizer *recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:theTarget action:theSelector] autorelease];
    recognizer.numberOfTouchesRequired = tapRequired;
    recognizer.direction = theDirection;
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:recognizer];
    return recognizer;
}


-(void)unWatch:(UIGestureRecognizer *)recognizer
{
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:recognizer];
}

@end
