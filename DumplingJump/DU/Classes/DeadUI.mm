//
//  DeadUI.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DeadUI.h"
#import "LevelManager.h"
#import "HeroManager.h"
#import "BoardManager.h"
#import "DeadAchievementUI.h"
#import "CCBReader.h"
#import "EquipmentData.h"
#import "AchievementNode.h"
#import "AchievementManager.h"
#import "GCHelper.h"
#import "TutorialManager.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>

@interface DeadUI()
@property (nonatomic, assign) int finalScore;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) int scoreDisplay;

@end

@implementation DeadUI
@synthesize isNew = _isNew;
@synthesize finalScore = _finalScore;
@synthesize distance = _distance;
@synthesize scoreDisplay = _scoreDisplay;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[DeadUI alloc] init];
    }
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"DeadUI.ccbi";
        priority = Z_DEADUI;
        winsize = [[CCDirector sharedDirector] winSize];
        _isNew = NO;
        _scoreDisplay = 0;
    }
    return self;
}

-(void) createUI
{
    [super createUI];
    [self createEquipmentView];
    [self updateNewAchievementSign];
}

- (void) createEquipmentView
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    equipmentViewController = [[EquipmentViewController alloc] initWithDelegate:self];
    equipmentView = [[[NSBundle mainBundle] loadNibNamed:@"EquipmentView" owner:equipmentViewController options:nil] objectAtIndex:0];
    equipmentView.center = ccp(winSize.width/2, winSize.height/2);
    equipmentView.layer.zPosition = Z_SECONDARY_UI;
    [equipmentView setHidden:YES];
    [VIEW addSubview:equipmentView];

    [equipmentViewController hideEquipmentView];
}



- (void) didAchievementTapped:(id)sender
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    [self setButtonsEnable:NO];
    [self setDeadUIVisible:NO callback:@selector(showAchievement)];
    [self setButtonsEnable:NO];
}

- (void) showAchievement
{
    _isNew = NO;
    [[DeadAchievementUI shared] createUI];
}

- (void) showEquipment
{
    [equipmentView setHidden:NO];
    [equipmentViewController showEquipmentView];
    [equipmentViewController updateStarNum:[[USERDATA objectForKey:@"star"] intValue]];
}

- (void) didEquipmentViewBack
{
    [equipmentView setHidden:YES];
    [self showDeadUI];
}

- (void) showDeadUI
{
    [self setButtonsEnable:YES];
    [self setDeadUIVisible:YES callback:nil];
    [self setButtonsEnable:YES];
    [self updateNewItemSign];
    [self updateNewAchievementSign];
}

- (void) updateNewAchievementSign
{
    if (_isNew)
    {
        [newAchievement stopAllActions];
        id scaleUp = [CCScaleTo actionWithDuration:0.1 scale:1.2];
        id scaleDown = [CCScaleTo actionWithDuration:0.4 scale:1];
        [newAchievement runAction:[CCRepeatForever actionWithAction: [CCSequence actions:scaleUp, scaleDown, nil]]];
        
        [newAchievement setVisible:YES];
    }
    else
    {
        [newAchievement stopAllActions];
        [newAchievement setVisible:NO];
    }
}

-(void) updateUIDataWithScore:(int)score Star:(int)star TotalStar:(int)totalStar Distance:(int)distance Multiplier:(float)multiplier IsHighScore:(BOOL)isHighScore
{
    _finalScore = score;
    _distance = distance;
    _scoreDisplay = 0;
    [scoreText setString:@"0"];
    [scoreTextWhite setString:@"0"];
    [starText setString:[NSString stringWithFormat:@"%d",star]];
    [totalStarText setString:[NSString stringWithFormat:@"%d",totalStar]];
    [distanceText setString:[NSString stringWithFormat:@"%dm",distance]];
    [multiplierText setString:[NSString stringWithFormat:@"%dx",(int)multiplier]];
    [highscoreSprite setOpacity:0];
    
    int xPos = 165;
    if (totalStar > 99999 || distance > 9999)
    {
        xPos = 152;
    }
    else if (totalStar > 9999 || distance > 999)
    {
        xPos = 158;
    }
    
    starText.position = ccp(xPos, starText.position.y);
    totalStarText.position = ccp(xPos, totalStarText.position.y);
    distanceText.position = ccp(xPos, distanceText.position.y);
    multiplierText.position = ccp(xPos, multiplierText.position.y);
    scoreText.opacity = 255;
    scoreTextWhite.opacity = 0;
    
//    if (isHighScore)
//    {
//        [highscoreSprite setOpacity:255];
//    }
//    else
//    {
//        [highscoreSprite setOpacity:0];
//    }
    
    [self updateNewItemSign];
    
    [retryButton setEnabled:NO];
    [self performSelector:@selector(playShowDistanceEffect) withObject:nil afterDelay:0.8];
    
    //Submite distance to Leaderboard
    [[GCHelper sharedInstance] reportScore:distance forLeaderboardID:@"edu.cmu.etc.CastleRider.distanceLB"];
}

-(void) playShowDistanceEffect
{
    //distance label pop
    id tweenDistance = [CCActionTween actionWithDuration:0.4 key:@"scoreDisplay" from: 0 to: _distance];
    [distanceText runAction:[self createPopMoveEffectWithDistance:15 withDuration:0.2]];
    [distanceText runAction:[self createPopScaleEffectWithDuration:0.15]];
    [self runAction:tweenDistance];
    //score label pop
    [scoreText runAction:[self createPopMoveEffectWithDistance:25 withDuration:0.2]];
    [scoreText runAction:[self createPopScaleEffectWithDuration:0.15]];
    [scoreTextWhite runAction:[self createPopMoveEffectWithDistance:25 withDuration:0.2]];
    [scoreTextWhite runAction:[self createPopScaleEffectWithDuration:0.15]];
    [self shiningScoreText];
    
    [self updateScoreLabelWithMeter:[NSNumber numberWithInt:_distance]];
    
    [self performSelector:@selector(playMultiplier) withObject:nil afterDelay:0.7];
}

-(void) playMultiplier
{
    [multiplierText runAction:[self createPopMoveEffectWithDistance:10 withDuration:0.2]];
    [multiplierText runAction:[self createPopScaleEffectWithDuration:0.15]];

    [scoreText runAction:[self createPopMoveEffectWithDistance:25 withDuration:0.2]];
    [scoreText runAction:[self createPopScaleEffectWithDuration:0.15]];
    [scoreTextWhite runAction:[self createPopMoveEffectWithDistance:25 withDuration:0.2]];
    [scoreTextWhite runAction:[self createPopScaleEffectWithDuration:0.15]];
    [self shiningScoreText];
    
    [scoreText setString:[NSString stringWithFormat:@"x%d",[[USERDATA objectForKey:@"multiplier"] intValue]]];
    [scoreTextWhite setString:[NSString stringWithFormat:@"x%d",[[USERDATA objectForKey:@"multiplier"] intValue]]];
    [self performSelector:@selector(playShowScoreEffect) withObject:nil afterDelay:0.5];
}

-(void) playShowScoreEffect
{
    _scoreDisplay = 0;
    id tweenScore = [CCActionTween actionWithDuration:0.4 key:@"scoreDisplay" from: 0 to: _finalScore];
    
    [self runAction:tweenScore];
    
    //score label pop
    [scoreText runAction:[self createPopMoveEffectWithDistance:25 withDuration:0.2]];
    [scoreText runAction:[self createPopScaleEffectWithDuration:0.15]];
    [scoreTextWhite runAction:[self createPopMoveEffectWithDistance:25 withDuration:0.2]];
    [scoreTextWhite runAction:[self createPopScaleEffectWithDuration:0.15]];
    [self shiningScoreText];
    
    [self updateScoreLabel:[NSNumber numberWithInt:_finalScore]];
    if (![[TutorialManager shared] isInStoreTutorial])
    {
        [retryButton setEnabled:YES];
    }
}

-(void) updateScoreLabel:(NSNumber *)target
{
    if (_scoreDisplay <= [target intValue])
    {
        [scoreText setString:[NSString stringWithFormat:@"%d", (int)_scoreDisplay]];
        [scoreTextWhite setString:[NSString stringWithFormat:@"%d", (int)_scoreDisplay]];
        if (_scoreDisplay < [target intValue])
        {
            [self performSelector:@selector(updateScoreLabel:) withObject:target afterDelay:0.01];
        }
    }
}

-(void) updateScoreLabelWithMeter:(NSNumber *)target
{
    if (_scoreDisplay <= [target intValue])
    {
        [scoreText setString:[NSString stringWithFormat:@"%dm", (int)_scoreDisplay]];
        [scoreTextWhite setString:[NSString stringWithFormat:@"%dm", (int)_scoreDisplay]];
        if (_scoreDisplay < [target intValue])
        {
            [self performSelector:@selector(updateScoreLabelWithMeter:) withObject:target afterDelay:0.01];
        }
    }
}

-(id) createPopMoveEffectWithDistance:(float)distance withDuration:(float)duration
{
    id moveUp = [CCMoveBy actionWithDuration:duration position:ccp(0,distance)];
    id moveDown = [CCMoveBy actionWithDuration:duration position:ccp(0,-distance)];
    return [CCSequence actions:moveUp, moveDown, nil];
}

-(id) createPopScaleEffectWithDuration:(float)duration
{
    id scaleUp = [CCScaleTo actionWithDuration:duration scale:1.3];
    id scaleDown = [CCScaleTo actionWithDuration:duration scale:1];
    return [CCSequence actions:scaleUp, scaleDown, nil];
}

-(void) shiningScoreText
{
    id fadeInNormal = [CCFadeIn actionWithDuration:0.1];
    id fadeInWhite = [CCFadeIn actionWithDuration:0.1];
    id delay1 = [CCDelayTime actionWithDuration:0.2];
    id delay2 = [CCDelayTime actionWithDuration:0.2];
    id fadeOutNormal = [CCFadeOut actionWithDuration:0.1];
    id fadeOutWhite = [CCFadeOut actionWithDuration:0.1];
    
    [scoreText runAction:[CCSequence actions:fadeOutNormal, delay1, fadeInNormal, nil]];
    [scoreTextWhite runAction:[CCSequence actions:fadeInWhite, delay2, fadeOutWhite, nil]];
}

-(void) updateNextMission:(NSDictionary *)nextMissionData
{
    [nextMission.UnlockIcon setVisible:NO];
    
    //update title
    [nextMission.MissionName setString:[nextMissionData objectForKey:@"name"]];
    
    //update description
    NSString *description2 = [nextMissionData objectForKey:@"description2"];
    if (description2 == nil)
    {
        description2 = @"";
    }
    [nextMission.DescriptionText setString:[NSString stringWithFormat:@"%@ %d %@", [nextMissionData objectForKey:@"description1"], [[nextMissionData objectForKey:@"number"] intValue], description2]];
    
    //percentage of how much you have finished (for life type)
    float percentage = [[AchievementManager shared] getFinishPercentageWithType:[nextMissionData objectForKey:@"type"] target:[[nextMissionData objectForKey:@"number"] floatValue]];
    
    [nextMission.Bar setScaleY:percentage];
}

-(void) updateNewItemSign
{
    int unlockItemNum = [[EquipmentData shared] isAffordable:[[USERDATA objectForKey:@"star"] intValue]];
    if (unlockItemNum > 0)
    {
        [newItemSprite setVisible:YES];
        [newItemText setVisible:YES];
        [newItemText setString:[NSString stringWithFormat:@"%d",unlockItemNum]];
        [self animateExclamationSign];
    }
    else
    {
        [newItemSprite setVisible:NO];
        [newItemText setVisible:NO];
    }
}

-(void) animateExclamationSign
{
    [newItemSprite stopAllActions];
    id scaleUp = [CCScaleTo actionWithDuration:0.1 scale:1.2];
    id scaleDown = [CCScaleTo actionWithDuration:0.4 scale:1];
    id restart = [CCCallFunc actionWithTarget:self selector:@selector(animateExclamationSign)];
    
    [newItemSprite runAction:[CCSequence actions:scaleUp, scaleDown, restart,nil]];
}

-(void) retry:(id)sender
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    [self setButtonsEnable:NO];
    [animationManager runAnimationsForSequenceNamed:@"Fade White"];
    id delay = [CCDelayTime actionWithDuration:0.2f];
    id restartFunc = [CCCallFunc actionWithTarget:[[Hub shared] gameLayer] selector:@selector(restart)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay,restartFunc,selfDestruction, nil];
    [node runAction:sequence];
}

-(void) didArsenalTapped:(id)sender
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    [self setButtonsEnable:NO];
    [self setDeadUIVisible:NO callback:@selector(showEquipment)];
    [self setButtonsEnable:NO];
    
    if ([[TutorialManager shared] isInStoreTutorial])
    {
        [self hideStoreTutorial];
        [[TutorialManager shared] startStoreTutorialPartTwo];
    }
}

-(void) setButtonsEnable:(BOOL)isEnable
{
    [homeButton setEnabled:isEnable];
    [missionButton setEnabled:isEnable];
    [equipmentButton setEnabled:isEnable];
    [retryButton setEnabled:isEnable];
    [facebookButton setEnabled:isEnable];
    [twitterButton setEnabled:isEnable];
}

-(void) didTapFacebook
{
    if ([SLComposeViewController instanceMethodForSelector:@selector(isAvailableForServiceType)] != nil)
    {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [facebookSheet setInitialText:[NSString stringWithFormat:@"I've just achieved %@ points and %@ in Castle Rider, come and challenge me!", scoreText.string, distanceText.string]];
            CCScene *scene = [[CCDirector sharedDirector] runningScene];
            CCNode *n = [scene.children objectAtIndex:0];
            UIImage *img = [self screenshotWithStartNode:n];
            [facebookSheet addImage:img];
//            [facebookSheet addURL:[NSURL URLWithString:@"http://www.google.com"]]; //TODO: replace with our website
            [[CCDirector sharedDirector] presentViewController:facebookSheet animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a facebook post right now, make sure your device has an internet connection and you have at least one Facebook account setup" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a facebook post right now, make sure to upgrade your device to iOS 6 or above" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }

}

-(void) didTapTwitter
{
    if ([SLComposeViewController instanceMethodForSelector:@selector(isAvailableForServiceType)] != nil)
    {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:[NSString stringWithFormat:@"I've just achieved %@ points and %@ in Castle Rider, come and challenge me!", scoreText.string, distanceText.string]];
            CCScene *scene = [[CCDirector sharedDirector] runningScene];
            CCNode *n = [scene.children objectAtIndex:0];
            UIImage *img = [self screenshotWithStartNode:n];
            [tweetSheet addImage:img];
//            [tweetSheet addURL:[NSURL URLWithString:@"http://www.google.com"]]; //TODO: replace with our website
            [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a tweet right now, make sure to upgrade your device to iOS 6 or above" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

-(UIImage*) screenshotWithStartNode:(CCNode*)startNode
{
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCRenderTexture* rtx =
    [CCRenderTexture renderTextureWithWidth:winSize.width
                                     height:winSize.height];
    [rtx begin];
    [startNode visit];
    [rtx end];
    
    return [rtx getUIImage];
}

-(void) home:(id)sender
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    [self setButtonsEnable:NO];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"]]];
}

- (void) setDeadUIVisible:(BOOL)isVisible callback:(SEL)selector
{
    CGPoint targetPosition;
    if (isVisible)
    {
        targetPosition = ccp(winsize.width/2.0, winsize.height/2.0);
    }
    else
    {
        targetPosition = ccp(winsize.width/2.0, winsize.height*1.5);
    }
    
    id moveToAnim = [CCMoveTo actionWithDuration:0.1 position:targetPosition];
    if (selector != nil)
    {
        id callbackFunc = [CCCallFunc actionWithTarget:self selector:selector];
        [rideAgainSprite runAction:[CCSequence actions:moveToAnim, callbackFunc, nil]];
    }
    else
    {
        [rideAgainSprite runAction:moveToAnim];
    }
}

-(void) showStoreTutorial
{
    //tutorialMask fade in
    [tutorialMask runAction:[CCFadeIn actionWithDuration:0.2]];
    
    //show hint arrow
    [hintArrow runAction:[CCFadeIn actionWithDuration:0.2]];
    
    //animate hint arrow
    id moveUp = [CCMoveBy actionWithDuration:0.5 position:ccp(0, 25)];
    id moveDown = [CCMoveBy actionWithDuration:0.5 position:ccp(0, -25)];
    
    [hintArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:moveUp, moveDown, nil]]];
    
    [equipmentButton setEnabled:YES];
}

-(void) hideStoreTutorial
{
    [tutorialMask runAction:[CCFadeOut actionWithDuration:0.2]];
    
    id stopAnimation = [CCCallBlock actionWithBlock:^{
        [hintArrow stopAllActions];
    }];
    
    [hintArrow runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.2], stopAnimation, nil]];
}

- (void) dealloc
{
    [equipmentViewController release];
    [super dealloc];
}

//===========================================
//===========UNUSED SHAKE EFFECT=============
//===========================================
//    NSMutableArray *actions = [NSMutableArray array];

//    id changeToRed = [CCCallBlock actionWithBlock:^{
//        CCSpriteFrame *warningRed = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"UI_play_warning.png"];
//        [newItemSprite setDisplayFrame:warningRed];
//    }];
//    [actions addObject:changeToRed];
//    int direction = 1;
//    for (int i=0; i<50; i++)
//    {
//        float angle;
//        if (direction > 0)
//        {
//            angle = randomFloat(5.0, 25.0);
//        }
//        else
//        {
//            angle = randomFloat(-25.0, -5.0);
//        }
//        direction = direction * -1;
//
//        id rotate = [CCRotateTo actionWithDuration:0.05 angle:angle];
//        [actions addObject:rotate];
//    }
//    id changeToNormal = [CCCallBlock actionWithBlock:^{
//        CCSpriteFrame *warningNormal = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"UI_retry_expression.png"];
//        [newItemSprite setDisplayFrame:warningNormal];
//        [newItemSprite setRotation:0];
//    }];
//    [actions addObject:changeToNormal];
//    id delay = [CCDelayTime actionWithDuration:2];
//    id restart = [CCCallFunc actionWithTarget:self selector:@selector(animateExclamationSign)];
//    [actions addObject:delay];
//    [actions addObject:restart];
@end
