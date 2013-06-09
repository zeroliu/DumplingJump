//
//  OptionUI.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "OptionUI.h"
#import "CCScale9Sprite.h"
@interface OptionUI()
{
    CGSize winSize;
}

@end
@implementation OptionUI
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[OptionUI alloc] init];
    }
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"OptionUI.ccbi";
        priority = Z_OPTIONUI;
        winSize = [CCDirector sharedDirector].winSize;
    }
    
    return self;
}

-(void) createUIwithParent:(CCNode *)parent
{
    [super createUIwithParent:parent];
    canvas.position = ccp(winSize.width/2,-winSize.height+BLACK_HEIGHT);
    bottom.position = ccp(winSize.width/2,-100+BLACK_HEIGHT);
    [self updateButtonsStatus];
}

-(void) updateButtonsStatus
{
    NSString *musicTogglePrefix = [[USERDATA objectForKey:@"music"] boolValue]?@"on":@"off";
    NSString *soundTogglePrefix = [[USERDATA objectForKey:@"sfx"] boolValue]?@"on":@"off";
    NSString *tutorialTogglePrefix = [[USERDATA objectForKey:@"tutorial"] boolValue]?@"on":@"off";
    
    [musicToggle setBackgroundSprite:[CCScale9Sprite spriteWithSpriteFrameName: [NSString stringWithFormat:@"UI_option_music_%@.png", musicTogglePrefix]] forState:CCControlStateNormal];
    [soundToggle setBackgroundSprite:[CCScale9Sprite spriteWithSpriteFrameName: [NSString stringWithFormat:@"UI_option_sound_%@.png", soundTogglePrefix]] forState:CCControlStateNormal];
    [tutorialToggle setBackgroundSprite:[CCScale9Sprite spriteWithSpriteFrameName: [NSString stringWithFormat:@"UI_option_tutorial_%@.png", tutorialTogglePrefix]] forState:CCControlStateNormal];
}

-(void) showUI
{
    //Move cavas up
    id canvasMoveUp = [CCMoveTo actionWithDuration:0.1 position:ccp(winSize.width/2, BLACK_HEIGHT)];
    [canvas runAction:canvasMoveUp];
    
    //Move bottom up
    id bottomMoveUp = [CCMoveTo actionWithDuration:0.1 position:ccp(winSize.width/2, BLACK_HEIGHT)];
    [bottom runAction:bottomMoveUp];
}

-(void) hideUI
{
    //Move cavas up
    id canvasMoveDown = [CCMoveTo actionWithDuration:0.1 position:ccp(winSize.width/2, -winSize.height+BLACK_HEIGHT)];
    [canvas runAction:canvasMoveDown];
    
    //Move bottom up
    id bottomMoveDown = [CCMoveTo actionWithDuration:0.1 position:ccp(winSize.width/2, -100+BLACK_HEIGHT)];
    [bottom runAction:bottomMoveDown];
}

-(void) didTapSoundToggle:(id)sender
{
    int currentStatus = [[USERDATA objectForKey:@"sfx"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:1-currentStatus] forKey:@"sfx"];
    [self updateButtonsStatus];
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
}

-(void) didTapMusicToggle:(id)sender
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    int currentStatus = [[USERDATA objectForKey:@"music"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:1-currentStatus] forKey:@"music"];
    if (currentStatus == 0)
    {
        //will turn on the music
        [[AudioManager shared] playBackgroundMusic:@"Music_MainMenu.mp3" loop:YES];
    }
    else
    {
        //will turn off the music
        [[AudioManager shared] stopBackgroundMusic];
    }
    [self updateButtonsStatus];
}

-(void) didTapTutorialToggle:(id)sender
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    int currentStatus = [[USERDATA objectForKey:@"tutorial"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:1-currentStatus] forKey:@"tutorial"];
    [self updateButtonsStatus];
}

- (void)dealloc
{
    [super dealloc];
}
@end
