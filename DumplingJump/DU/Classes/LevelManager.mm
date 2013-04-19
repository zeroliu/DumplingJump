//
//  LevelManager.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "LevelManager.h"
#import "HeroManager.h"
#import "BoardManager.h"
#import "BackgroundController.h"
#import "AddthingFactory.h"
#import "AddthingObject.h"
#import "AddthingObjectData.h"
#import "StarManager.h"
#import "Paragraph.h"
#import "GameUI.h"
#import "LevelTestTool.h"
#import "GameModel.h"
#import "PowderInfo.h"
#import "Constants.h"

@interface DropInfo : NSObject
@property (nonatomic, retain) NSString *objectName;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) double warningTime;
@property (nonatomic, retain) CCSprite *warningSignSprite;
@property (nonatomic, assign) double originWarningTime;
@property (nonatomic, assign) BOOL hasGenerated;

- (id) initWithObjectName:(NSString *)objectName position:(CGPoint)position warningTime:(double)warningTime sprite:(CCSprite *)warningSignSprite;
@end

@implementation DropInfo
@synthesize
objectName = _objectName,
position = _position,
warningTime = _warningTime,
warningSignSprite = _warningSignSprite,
originWarningTime = _originWarningTime,
hasGenerated = _hasGenerated;

- (id) initWithObjectName:(NSString *)objectName position:(CGPoint)position warningTime:(double)warningTime sprite:(CCSprite *)warningSignSprite
{
    if (self = [super init])
    {
        _objectName = [objectName retain];
        _position = position;
        _warningSignSprite = [warningSignSprite retain];
        _warningTime = warningTime;
        _originWarningTime = warningTime;
        _hasGenerated = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [_objectName release];
    [_warningSignSprite release];
    [super dealloc];
}
@end

@interface LevelManager()
{
    int currentPhaseIndex;
    NSMutableArray *phasePharagraphs;
    int sentenceIndex;
    float sentenceCounter;
    float sentenceTarget;
    Paragraph *currentParagraph;
    BOOL isWaiting;
    id waitingAction;
    NSMutableArray *warningSignArray;
    BOOL isProcessingWarningSign;
    BOOL isUpdatingPowderCountdown;
    BOOL isMirror;
}

@property (nonatomic, retain) LevelData *levelData;
@property (nonatomic, retain) NSDictionary *paragraphsData;
@property (nonatomic, retain) NSArray *paragraphsCombination;
@property (nonatomic, retain) NSArray *paragraphNames; //Array used to save paragraph (level) names
@end

@implementation LevelManager
@synthesize
levelData = _levelData,
generatedObjects = _generatedObjects,
paragraphsData = _paragraphsData,
paragraphsCombination = _paragraphsCombination,
paragraphNames = _paragraphNames,
powderDictionary = _powderDictionary,
toRemovePowderArray = _toRemovePowderArray;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[LevelManager alloc] init];
    }
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        phasePharagraphs = nil;
        
        _generatedObjects = [[NSMutableArray alloc] init];
        warningSignArray = [[NSMutableArray alloc] init];
        _toRemovePowderArray = [[NSMutableArray alloc] init];
        isMirror = NO;
        //Scan all the files in xmls/levels folder and save it into paragraphsData dictionary
        self.paragraphsData = [[XMLHelper shared] loadParagraphFromFolder:@"xmls/levels"];
        
        //Save all the paragraph names
        self.paragraphNames = [[self.paragraphsData allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2];
        }];
        
        //Load combination data from Editor_level.xml
        self.paragraphsCombination = [[XMLHelper shared] loadParagraphCombinationWithXML:@"Editor_level"];
        
        //TODO: Create weight look up table for the combinations
        
        currentPhaseIndex = 0;
        _powderDictionary = [[NSMutableDictionary alloc] init];
        [self clearWarningSign];
        [self clearWaitingAction];
        [self clearPowderCountdownDictionary];
    }
    
    return self;
}

-(id) levelData
{
    if (_levelData == nil) _levelData = [[LevelData alloc] init];
    return _levelData;
}

-(void) restart
{
    //Destroy all objects
    [[LevelManager shared] destroyAllObjectsWithoutAnimation];
    
    //Reset Level
    [[LevelManager shared] stopCurrentParagraph];
    [[LevelManager shared] resetParagraph];
    
    [self clearWaitingAction];
    [self clearWarningSign];
    [self clearPowderCountdownDictionary];
}

-(Level *) selectLevelWithName:(NSString *)levelName
{
    return [self.levelData getLevelByName:levelName];
}

-(void) dropAddthingWithName:(NSString *)objectName atSlot:(int)num warning:(double)warningTime
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float xPosUnit = (winSize.width-5) / (float)SLOTS_NUM;
    
    [self dropAddthingWithName:objectName atPosition:ccp(xPosUnit * num + 5 + xPosUnit/2,[[CCDirector sharedDirector] winSize].height-BLACK_HEIGHT+100) warning:warningTime];
}

-(void) dropAddthingWithName:(NSString *)objectName atPosition:(CGPoint)position warning:(double)warningTime
{
    
    CCSprite *warningSign = [CCSprite spriteWithSpriteFrameName:@"UI_play_warning.png"];
    warningSign.position = ccp(position.x,[[CCDirector sharedDirector] winSize].height-BLACK_HEIGHT-30);
    warningSign.scale = 0;
    id zoomInEffect = [CCScaleTo actionWithDuration:0.3 scale:0.8];
    [warningSign runAction:zoomInEffect];
    [GAMELAYER addChild:warningSign z:Z_WarningSign];
    
    DropInfo *dropInfo = [[DropInfo alloc] initWithObjectName:objectName position:position warningTime:warningTime sprite:warningSign];
    
    [warningSignArray addObject:dropInfo];
    
    [dropInfo release];
}

-(id) dropAddthingWithName:(NSString *)objectName atSlot:(int) num
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float xPosUnit = (winSize.width-5) / (float)SLOTS_NUM;
    
    return [self dropAddthingWithName:objectName atPosition:ccp(xPosUnit * num + 5 + xPosUnit/2,[[CCDirector sharedDirector] winSize].height-BLACK_HEIGHT+100)];
}

-(id) dropAddthingWithName:(NSString *)objectName atPosition:(CGPoint)position
{
    NSString *dropObjectName = objectName;
    if ([objectName rangeOfString:@"RANDOM"].location != NSNotFound)
    {
        dropObjectName = [self treatRandomObject:[[AddthingFactory shared] getCustomDataByName:objectName]];
    }
    
    if ([dropObjectName isEqualToString:@"NOTHING"])
    {
        return nil;
    }
    
    //The equipment hasnot unlocked yet
    if ([[USERDATA objectForKey:dropObjectName] intValue] < 0)
    {
        return nil;
    }
    
    AddthingObject *addthing = [[[AddthingFactory shared] createWithName:dropObjectName] retain];
    addthing.sprite.position = position;
    [self.generatedObjects addObject:addthing];
    int depth = 3;
    if ([dropObjectName isEqualToString:@"STAR"])
    {
        depth = 1;
    }
    [addthing addChildTo:BATCHNODE z:depth];
    
    if ([dropObjectName isEqualToString:@"POWDER"] || [dropObjectName isEqualToString:@"BOMB"])
    {
        float countdown = addthing.reaction.reactTime;
        CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", (int)countdown] fntFile:@"ERAS_red_black.fnt"];
        [GAMELAYER addChild:label z:Z_BATCHNODE+1];
        PowderInfo *powderInfo = [[[PowderInfo alloc] initWithAddthing:addthing label:label countdown:countdown] autorelease];
        [_powderDictionary setObject:powderInfo forKey:addthing.ID];
    }
    return addthing;
}

- (void) generateFloatingStar:(CGPoint)position
{
    DUSprite *flyingStar = [[DUSprite alloc] initWithName:@"flyingStar" file:@"A_star_1.png"];
    flyingStar.sprite.scale = 1.5;
    flyingStar.sprite.position = position;
    id rotateStar = [CCRotateBy actionWithDuration:0.3 angle:90];
    id moveUp = [CCMoveTo actionWithDuration:0.3 position:ccp(position.x, position.y+40)];
    id fadeStar = [CCFadeTo actionWithDuration:0.3 opacity:200];
    id moveToDestination = [CCMoveTo actionWithDuration:0.2 position:[[GameUI shared] getStarDestination]];
    id scaleDown = [CCScaleTo actionWithDuration:0.2 scale:0.6];
    id remove = [CCCallBlock actionWithBlock:^{
        [[GameUI shared] scaleStarUI];
        [flyingStar archive];
    }];
    [flyingStar.sprite runAction:rotateStar];
    [flyingStar.sprite runAction:[CCSequence actions:moveUp, scaleDown, nil]];
    [flyingStar.sprite runAction:[CCSequence actions:fadeStar, moveToDestination, remove, nil]];
    [flyingStar addChildTo:BATCHNODE z:1];
}

- (void) generateFlyingStarAtPosition:(CGPoint)position destination:(CGPoint)destination
{
    DUSprite *flyingStar = [[DUSprite alloc] initWithName:@"flyingStar" file:@"A_star_1.png"];
    flyingStar.sprite.position = position;
    id moveToDestination = [CCMoveTo actionWithDuration:0.4 position:destination];
    id scaleDown = [CCScaleTo actionWithDuration:0.4 scale:0.6];
    id remove = [CCCallBlock actionWithBlock:^{
        [[GameUI shared] scaleStarUI];
        [flyingStar archive];
    }];
    [flyingStar.sprite runAction:scaleDown];
    [flyingStar.sprite runAction:[CCSequence actions:moveToDestination, remove, nil]];
    [flyingStar addChildTo:BATCHNODE z:1];
}

- (void) generateMegaFlyingStarAtPosition:(CGPoint)position
{
    for (int i=0; i<10; i++)
    {
        float currentAngle = 36.0*i * M_PI / 180.0;
        CGPoint floatTarget = ccp(position.x+60*sin(currentAngle), position.y+60*cos(currentAngle));
        DUSprite *flyingStar = [[DUSprite alloc] initWithName:@"flyingStar" file:@"A_star_1.png"];
        flyingStar.sprite.position = position;
        id rotateStar = [CCRotateBy actionWithDuration:0.5 angle:90];
        id moveUp = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.5 position:floatTarget]];
        id fadeStar = [CCFadeTo actionWithDuration:0.5 opacity:200];
        id delay = [CCDelayTime actionWithDuration:0.05*i];
        id wait = [CCDelayTime actionWithDuration:0.05*(10-i)];
        id moveToDestination = [CCMoveTo actionWithDuration:0.2 position:[[GameUI shared] getStarDestination]];
        id scaleDown = [CCScaleTo actionWithDuration:0.2 scale:0.6];
        id remove = [CCCallBlock actionWithBlock:^{
            [[GameUI shared] scaleStarUI];
            [flyingStar archive];
        }];
        [flyingStar.sprite runAction:rotateStar];
        [flyingStar.sprite runAction:[CCSequence actions:delay, moveUp, wait, scaleDown, nil]];
        [flyingStar.sprite runAction:[CCSequence actions:delay, fadeStar, wait, moveToDestination, remove, nil]];
        [flyingStar addChildTo:BATCHNODE z:1];
    }
}

- (NSString *) treatRandomObject:(NSString *)randomInfo
{
    NSArray *combinationArray = [randomInfo componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[combinationArray count]];
    NSMutableArray *weights = [[NSMutableArray alloc] initWithCapacity:[combinationArray count]];
    NSString *result = nil;
    int sum = 0;
    
    for (NSString *combination in combinationArray)
    {
        NSArray *data = [combination componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        [objects addObject: [data objectAtIndex:0]];
        
        int weight = sum + [[data objectAtIndex:1] intValue];
        sum = weight;
        
        [weights addObject:[NSNumber numberWithInt:weight]];
    }
    
    int randomNum = randomInt(1, sum);
    
    for (int i=0; i<[combinationArray count]; i++)
    {
        int currentWeight = [[weights objectAtIndex:i] intValue];
        if (currentWeight >= randomNum)
        {
            result = [objects objectAtIndex:i];
            break;
        }
    }
    
    [objects release];
    [weights release];
    return result;
}

-(void) loadParagraphWithName:(NSString *)name
{
    sentenceCounter = 0;
    sentenceIndex = 0;
    sentenceTarget = 0;
    
    currentParagraph = [_paragraphsData objectForKey:name];
    
    if ([name rangeOfString:@"*"].location != NSNotFound)
    {
        //the paragraph is not reversible
        isMirror = NO;
    }
    else
    {
        int mirrorRate = randomInt(0, 2);
        isMirror = NO;
        if (mirrorRate > 0)
        {
            isMirror = YES;
        }
    }
    
    if (currentParagraph == nil)
    {
        [[LevelTestTool shared] updateLevelName:@"error: No such level"];
    } else
    {
        [[LevelTestTool shared] updateLevelName:name];
    }
}

-(void) loadCurrentParagraph
{
    sentenceCounter = 0;
    sentenceIndex = 0;
    sentenceTarget = 0;
    
    if (phasePharagraphs == nil)
    {
        int selectedCombination = randomInt(0, [[self.paragraphsCombination objectAtIndex:currentPhaseIndex] count]);
        phasePharagraphs = [[NSMutableArray arrayWithArray:[[self.paragraphsCombination objectAtIndex:currentPhaseIndex] objectAtIndex:selectedCombination]] retain];
        DLog(@"Level numbers: %d", [[self.paragraphsCombination objectAtIndex:currentPhaseIndex] count]);
        DLog(@"Phase No.%d loaded", currentPhaseIndex);
    }
    
    //Get the first one in the array
    NSString *currentParagraphName = [phasePharagraphs objectAtIndex:0];
    
    if ([currentParagraphName rangeOfString:@"*"].location != NSNotFound)
    {
        //the paragraph is not reversible
        isMirror = NO;
    }
    else
    {
        int mirrorRate = randomInt(0, 2);
        isMirror = NO;
        if (mirrorRate > 0)
        {
            isMirror = YES;
        }
    }
    
    //Load the paragraph data of this name
    currentParagraph = [_paragraphsData objectForKey:currentParagraphName];
    
    if (currentParagraph != nil)
    {
        DLog(@"Now playing level %@", currentParagraphName);
    } else
    {
        DLog(@"Loading level %@ error", currentParagraphName);
    }
    
    [[LevelTestTool shared] updateLevelName:currentParagraphName];
    
    //Remove the first element of the array
    [phasePharagraphs removeObjectAtIndex:0];
    
    //If the array is empty
    if ([phasePharagraphs count] == 0)
    {
        //Set the array to nil
        [phasePharagraphs release];
        phasePharagraphs = nil;
    }
    
}

-(int) paragraphsCount
{
    return [self.paragraphsData count];
}

-(void) dropNextAddthing
{
    if (currentParagraph != nil && !isWaiting)
    {
        sentenceCounter += [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"dropRate"] floatValue] * GAMEMODEL.dropRateIncrease;
        if (sentenceTarget <= sentenceCounter)
        {
            //Trigger a sentence
            Sentence *mySentence = [currentParagraph getSentenceAtIndex:sentenceIndex];
            double waitingTime = 0;
            for (int i=0; i<SLOTS_NUM; i++)
            {
                int dropSlot = i;
                if (isMirror)
                {
                    dropSlot = SLOTS_NUM - i - 1;
                }
                NSString *item = [mySentence.words objectAtIndex:i];
                if ([item rangeOfString:@"(*)"].location != NSNotFound)
                {
                    [[StarManager shared] dropRandomStar];
                    double starWait = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"starWait"] doubleValue];
                    waitingTime = MAX(waitingTime, starWait);
                }
                else if ([item rangeOfString:@"*"].location == 0)
                {
                    [[StarManager shared] dropStar:item AtSlot:dropSlot];
                    double starWait = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"starWait"] doubleValue];
                    waitingTime = MAX(waitingTime, starWait);
                } else
                {
                    if (![item isEqualToString: NOTHING])
                    {
                        double warningTime = ((AddthingObjectData *)[((AddthingFactory *)[AddthingFactory shared]).addthingDictionary objectForKey:item]).warningTime;
                        if (warningTime > 0)
                        {
                            [self dropAddthingWithName:item atSlot:dropSlot warning:warningTime];
                        }
                        else
                        {
                            AddthingObject *addthing = [self dropAddthingWithName:item atSlot:dropSlot];
                            waitingTime = MAX(waitingTime, addthing.wait);
                        }
                    }
                }
            }
            
            [self stopDroppingForTime:waitingTime];
            
            sentenceIndex ++;
            
            if (sentenceIndex < [currentParagraph countSentencesNum])
            {
                //If there are still sentences, set new sentence target
                sentenceTarget = ((Sentence *)[currentParagraph getSentenceAtIndex:sentenceIndex]).distance;
            } else
            {
                [self jumpToNextLevel];
            }
        }
    }
}

-(void) jumpToNextLevel
{
    //update game speed
    [GAMEMODEL updateGameSpeed];
    
    //current paragraph finished
    currentParagraph = nil;
    
    //If finished currentPhase, move to next phase
    if (phasePharagraphs == nil)
    {
        currentPhaseIndex ++;
        int phaseTotalNum = [_paragraphsCombination count];
        DLog(@"new phase TotalNum = %d", phaseTotalNum);
        if (currentPhaseIndex >= phaseTotalNum)
        {
            currentPhaseIndex = 1;
        }
        
        DLog(@"Phase ends, now loading phase No.%d", currentPhaseIndex);
    }
    
    /*
    id switchToNextLevelAction = [CCCallFunc actionWithTarget:self selector:@selector(switchToNextLevelEffect)];
    id delay1 = [CCDelayTime actionWithDuration:4];
    id loadParagraphAction = [CCCallFunc actionWithTarget:self selector:@selector(loadCurrentParagraph)];
    id delay2 = [CCDelayTime actionWithDuration:4];
    
    [GAMELAYER runAction:[CCSequence actions:delay1, switchToNextLevelAction, delay2, loadParagraphAction, nil]];
     */
    id delay1 = [CCDelayTime actionWithDuration:[[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"levelTransitionDelay"] floatValue]];
    id loadParagraphAction = [CCCallFunc actionWithTarget:self selector:@selector(loadCurrentParagraph)];
    [GAMELAYER runAction:[CCSequence actions:delay1, loadParagraphAction, nil]];
}

-(void) switchToNextLevelEffect
{
    [self rocketEffectWithDuration:3];
}

-(void) rocketEffectWithDuration:(float)interval
{
    [[[HeroManager shared] getHero] rocketPowerup:interval];
    [[[BoardManager shared] getBoard] rocketPowerup:interval];
    
    //Speed up scrolling speed
    [[BackgroundController shared] speedUpWithScale:6 interval:interval];
    
    //Play speed line effect
    CCNode *particleNode = [[DUParticleManager shared] createParticleWithName:@"FX_speedline.ccbi" parent:GAMELAYER z:Z_Speedline duration: MAX(1, interval-1) life:1];
    particleNode.position = CGPointZero;
}

-(void) stopCurrentParagraph
{
    currentParagraph = nil;
}

-(void) resetParagraph
{
    currentPhaseIndex = 0;
    [phasePharagraphs removeAllObjects];
    [phasePharagraphs release];
    phasePharagraphs = nil;
}

-(void) removeObjectFromList:(DUObject *)myObject
{
    [self.generatedObjects removeObject:myObject];
}

-(void) destroyAllObjects
{
    NSArray *array = [self.generatedObjects copy];
    for (AddthingObject *ob in array)
    {
        [ob removeAddthing];
    }
    [array release];
}

-(void) destroyAllObjectsWithoutAnimation
{
    NSArray *array = [self.generatedObjects copy];
    for (AddthingObject *ob in array)
    {
        [ob removeAddthingWithoutAnimation];
    }
    [array release];
}

-(NSString *) getParagraphNameByIndex:(int)index
{
    //DLog(@"%@", self.paragraphNames);
    
    if (index < [self.paragraphNames count])
    {
        return [self.paragraphNames objectAtIndex:index];
    }
    else
    {
        return @"Wrong index";
    }
}

-(void) clearWaitingAction
{
    [GAMELAYER stopAction:waitingAction];
    [waitingAction release];
    waitingAction = nil;
    isWaiting = NO;
}

-(void) stopDroppingForTime:(double)waitingTime
{
    if (waitingTime <=0)
        return;
    
    [self clearWaitingAction];
    
    //Set waiting to YES
    isWaiting = YES;
    
    //Wait for <waitingTime> seconds
    id waiting = [CCDelayTime actionWithDuration:waitingTime];
    
    //Set waiting to NO
    id endWaiting = [CCCallBlock actionWithBlock:^{
        isWaiting = NO;
    }];
    
    waitingAction = [[CCSequence actions:waiting, endWaiting, nil] retain];
    [GAMELAYER runAction:waitingAction];
}

- (void) clearWarningSign
{
    isProcessingWarningSign = NO;
    for (DropInfo *info in warningSignArray)
    {
        [info.warningSignSprite stopAllActions];
        [info.warningSignSprite removeFromParentAndCleanup:NO];
    }
    [warningSignArray removeAllObjects];
}

- (void) clearPowderCountdownDictionary
{
    
    for (NSString *addthingID in [_powderDictionary allKeys])
    {
        PowderInfo *info = [_powderDictionary objectForKey:addthingID];
        [info.countdownLabel removeFromParentAndCleanup:NO];
    }
    [_powderDictionary removeAllObjects];
    [_toRemovePowderArray removeAllObjects];
    isUpdatingPowderCountdown = NO;
}

- (void) updateWarningSign
{
    if (!isProcessingWarningSign)
    {
        isProcessingWarningSign = YES;
        NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
        float unit = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"dropRate"] floatValue] * GAMEMODEL.dropRateIncrease;
        for (DropInfo *info in warningSignArray)
        {
            info.warningTime -= unit;
            if (info.warningTime <= 0 && !info.hasGenerated)
            {
                info.hasGenerated = YES;
                [self dropAddthingWithName:info.objectName atPosition:info.position];
            }
            if (info.warningTime <= -0.5)
            {
                [info.warningSignSprite stopAllActions];
                [info.warningSignSprite removeFromParentAndCleanup:NO];
                [objectsToRemove addObject:info];
            }
        }
        for (DropInfo *toRemoveInfo in objectsToRemove)
        {
            [warningSignArray removeObject:toRemoveInfo];
        }
        [objectsToRemove removeAllObjects];
        [objectsToRemove release];
        isProcessingWarningSign = NO;
    }
}

- (void) updatePowderCountdown:(ccTime)deltaTime
{
    if (!isUpdatingPowderCountdown)
    {
        isUpdatingPowderCountdown = YES;
        for (NSString *toRemoveAddthingID in _toRemovePowderArray)
        {
            [((PowderInfo *)[_powderDictionary objectForKey:toRemoveAddthingID]).countdownLabel removeFromParentAndCleanup:NO];
            [_powderDictionary removeObjectForKey:toRemoveAddthingID];
        }
        for (NSString *addthingID in [_powderDictionary allKeys])
        {
            PowderInfo *info = [_powderDictionary objectForKey:addthingID];
            info.countdown -= deltaTime;
            [info.countdownLabel setString:[NSString stringWithFormat:@"%d",(int)info.countdown]];
            info.countdownLabel.position = ccpAdd(((AddthingObject *)info.addthing).position, ccp(0,55));
        }
        isUpdatingPowderCountdown = NO;
    }
}

- (void)dealloc
{
    [phasePharagraphs release];
    [_levelData release];
    [_paragraphsData release];
    [_paragraphsCombination release];
    [_generatedObjects release];
    [_paragraphNames release];
    [warningSignArray release];
    [_powderDictionary release];
    [_toRemovePowderArray release];
    [super dealloc];
}
@end
