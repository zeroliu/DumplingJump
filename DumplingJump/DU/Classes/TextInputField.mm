//
//  LevelTestTool.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-24.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "TextInputField.h"
@implementation TextInputField
@synthesize fieldValue;
-(id) initWithParent:(id)parent Selector:(SEL)parentSelector Position:(CGPoint)position Size:(CGPoint)size DisplayField:(CCMenuItemFont *)display
{
    if (self = [super init])
    {
        _parent = parent;
        _parentSelector = parentSelector;
        _position = position;
        _size = size;
        _display = display;
        [self reload];
    }
    
    return self;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _textField)
    {
        [_textField endEditing:YES];
        fieldValue = _textField.text;
        [_textField setText:@""];
        [_display setString:fieldValue];
        [_parent performSelector:_parentSelector withObject:fieldValue];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) reload
{
    _myView = [[CCDirector sharedDirector] view];
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(_position.x, _position.y, _size.x, _size.y)];
    [_textField setText:@""];
    [_textField setDelegate:self];
    _textField.clearsOnBeginEditing = NO;
    _textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [_myView addSubview:_textField];
    [[[[CCDirector sharedDirector] view] window] addSubview:_myView];
}
@end
