//
//  ItemUnlockUI.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "ItemUnlockUI.h"
#import "DeadUI.h"
#import "CCBReader.h"
#import "UserData.h"
#import "EquipmentData.h"

@implementation ItemUnlockUI
@synthesize starNum = _starNum;
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[ItemUnlockUI alloc] init];
    }
    return shared;
}



-(void) createUI
{
    [super createUI];
    [self updateData];
}

-(void) updateData
{
    //increase multiplier
    int currentMultiplier = [[USERDATA objectForKey:@"multiplier"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:currentMultiplier + 1] forKey:@"multiplier"];
    
    //increase current group
    int currentGroup = [[USERDATA objectForKey:@"achievementGroup"] intValue];
    if (currentGroup < 9)
    {
        [USERDATA setObject:[NSNumber numberWithInt:currentGroup + 1] forKey:@"achievementGroup"];
        //Show dead UI achievement exclamation sign
        ((DeadUI *)[DeadUI shared]).isNew = YES;
    }
    [onMedalMultiplierText setString:[NSString stringWithFormat:@"%dx", currentGroup+1]];
    [multiplierNum setString:[NSString stringWithFormat:@"%dx", currentGroup+1]];
    
    _starNum = 0;
    targetStarNum = [[StarRewardData shared] loadRewardStarNumWithGroupID:currentGroup];
    float totalStar = [[USERDATA objectForKey:@"star"] floatValue];
    [USERDATA setObject:[NSNumber numberWithFloat:totalStar + targetStarNum] forKey:@"star"];
    
    id delay = [CCDelayTime actionWithDuration:3.6];
    id tweenNum = [CCActionTween actionWithDuration:1 key:@"starNum" from: 0 to: targetStarNum];
    id showParticle = [CCCallBlock actionWithBlock:^{
        CCNode *particleNode = [[DUParticleManager shared] createParticleWithName:@"FX_itemGet.ccbi" parent:nodeHolder z:starIcon.zOrder+10];
        particleNode.position = starIcon.position;
    }];
    [self runAction:[CCSequence actions:delay, tweenNum, showParticle, nil]];
    
    [self performSelector:@selector(updateStarNum)];
    
    [forwardButton setEnabled:YES];
}

-(void) updateStarNum
{
    if (_starNum <= targetStarNum)
    {
        [starText setString:[NSString stringWithFormat:@"+%d", (int)_starNum]];
        if (_starNum < targetStarNum)
        {
            [self performSelector:@selector(updateStarNum) withObject:nil afterDelay:0.01];
        }
    }
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"ItemGetUI.ccbi";
        priority = Z_DEADUI+1;
        winsize = [[CCDirector sharedDirector] winSize];
    }
    
    return self;
}

-(void)didTapForward:(id)sender
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    [forwardButton setEnabled:NO];
    
    [animationManager runAnimationsForSequenceNamed:@"Fly Up"];
    id delay = [CCDelayTime actionWithDuration:0.5];
    id resumeGameFunc = [CCCallFunc actionWithTarget:GAMELAYER selector:@selector(showDeadUI)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay, resumeGameFunc, selfDestruction, nil];
    
    [node runAction:sequence];
}

- (void) dealloc
{
//    [multiplierNum release];
//    [onMedalMultiplierText release];
//    [starText release];
//    [starIcon release];

    [super dealloc];
}

@end
