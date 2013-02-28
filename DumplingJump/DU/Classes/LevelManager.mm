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
}

@property (nonatomic, retain) LevelData *levelData;
@property (nonatomic, retain) NSDictionary *paragraphsData;
@property (nonatomic, retain) NSArray *paragraphsCombination;
@property (nonatomic, retain) NSArray *paragraphNames; //Array used to save paragraph (level) names
@end

@implementation LevelManager
@synthesize levelData = _levelData, generatedObjects = _generatedObjects, paragraphsData = _paragraphsData, paragraphsCombination = _paragraphsCombination, paragraphNames = _paragraphNames;

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
        [self clearWarningSign];
        [self clearWaitingAction];
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
    [[LevelManager shared] destroyAllObjects];
    
    //Reset Level
    [[LevelManager shared] stopCurrentParagraph];
    [[LevelManager shared] resetParagraph];
    
    [self clearWaitingAction];
    [self clearWarningSign];
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
    CCSprite *warningSign = [CCSprite spriteWithFile:@"UI_retry_expression.png"];
    warningSign.position = ccp(position.x,[[CCDirector sharedDirector] winSize].height-BLACK_HEIGHT-30);
    warningSign.scale = 0;
    id zoomInEffect = [CCScaleTo actionWithDuration:0.3 scale:0.8];
    [warningSign runAction:zoomInEffect];
    [GAMELAYER addChild:warningSign];
    
    DropInfo *dropInfo = [[DropInfo alloc] initWithObjectName:objectName position:position warningTime:warningTime sprite:warningSign];
    
    [warningSignArray addObject:dropInfo];
}

-(id) dropAddthingWithName:(NSString *)objectName atPosition:(CGPoint)position
{
    DUPhysicsObject *addthing = [[[AddthingFactory shared] createWithName:objectName] retain];
    
    addthing.sprite.position = position;
    [self.generatedObjects addObject:addthing];
    int depth = 3;
    if ([objectName isEqualToString:@"STAR"])
    {
        depth = 1;
    }
    [addthing addChildTo:BATCHNODE z:depth];
    return addthing;
}

-(id) dropAddthingWithName:(NSString *)objectName atSlot:(int) num
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float xPosUnit = (winSize.width-5) / (float)SLOTS_NUM;
    
    return [self dropAddthingWithName:objectName atPosition:ccp(xPosUnit * num + 5 + xPosUnit/2,[[CCDirector sharedDirector] winSize].height-BLACK_HEIGHT+100)];
}

-(void) loadParagraphWithName:(NSString *)name
{
    sentenceCounter = 0;
    sentenceIndex = 0;
    sentenceTarget = 0;
    
    currentParagraph = [_paragraphsData objectForKey:name];
    
    if (currentParagraph == nil)
    {
        [[LevelTestTool shared] updateLevelName:@"error: No such level"];
    } else
    {
        [[LevelTestTool shared] updateLevelName:name];
    }
    //currentParagraph = [[self.paragraphs objectAtIndex:0] objectAtIndex:index];
    //currentParagraphIndex = index;
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
    //currentParagraph = [[self.paragraphs objectAtIndex:0] objectAtIndex:currentParagraphIndex];
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
        sentenceCounter += [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"dropRate"] floatValue] * ((GAMEMODEL.gameSpeed-1)/2+1);
        if (sentenceTarget <= sentenceCounter)
        {
            //Trigger a sentence
            Sentence *mySentence = [currentParagraph getSentenceAtIndex:sentenceIndex];
            double waitingTime = 0;
            for (int i=0; i<SLOTS_NUM; i++)
            {
                NSString *item = [mySentence.words objectAtIndex:i];
                if ([item rangeOfString:@"*"].location == 0)
                {
                    [[StarManager shared] dropStar:item AtSlot:i];
                    double starWait = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"starWait"] doubleValue];
                    waitingTime = MAX(waitingTime, starWait);
                } else
                {
                    if (![item isEqualToString: NOTHING])
                    {
                        double warningTime = ((AddthingObjectData *)[((AddthingFactory *)[AddthingFactory shared]).addthingDictionary objectForKey:item]).warningTime;
                        if (warningTime > 0)
                        {
                            [self dropAddthingWithName:item atSlot:i warning:warningTime];
                        }
                        else
                        {
                            AddthingObject *addthing = [self dropAddthingWithName:item atSlot:i];
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
    id delay1 = [CCDelayTime actionWithDuration:[[[WorldData shared] loadDataWithAttributName:@"levelTransitionDelay"] floatValue]];
    id loadParagraphAction = [CCCallFunc actionWithTarget:self selector:@selector(loadCurrentParagraph)];
    [GAMELAYER runAction:[CCSequence actions:delay1, loadParagraphAction, nil]];
}

-(void) switchToNextLevelEffect
{
    [self rocketEffectWithDuration:3];
    
    //Show Stage clear text
    [[GameUI shared] showStageClearMessageWithDistance];
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

- (void) updateWarningSign
{
    if (!isProcessingWarningSign)
    {
        isProcessingWarningSign = YES;
        NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
        float unit = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"dropRate"] floatValue] * ((GAMEMODEL.gameSpeed-1)/2+1);
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

- (void)dealloc
{
    [phasePharagraphs release];
    [_levelData release];
    [_paragraphsData release];
    [_paragraphsCombination release];
    [_generatedObjects release];
    [_paragraphNames release];
    [warningSignArray release];
    [super dealloc];
}
@end
