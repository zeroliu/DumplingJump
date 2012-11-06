//
//  TextInputField.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-4.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "cocos2d.h"

@interface TextInputField : CCNode <UITextFieldDelegate>
{
    UITextField *_textField;
    UIView *_myView;
    SEL _parentSelector;
    id _parent;
    CGPoint _position;
    CGPoint _size;
    CCMenuItemFont *_display;
}

@property (nonatomic, retain) NSString *fieldValue;

-(id) initWithParent:(id)parent Selector:(SEL)parentSelector Position:(CGPoint)position Size:(CGPoint)size DisplayField:(CCMenuItemFont *)display;
@end
