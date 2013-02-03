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
#import "StarManager.h"
#import "Paragraph.h"
#import "GameUI.h"
#import "LevelTestTool.h"
#import "GameModel.h"

@interface LevelManager()
{
    //int currentParagraphIndex;
    
    int currentPhaseIndex;
    NSMutableArray *phasePharagraphs;
    int sentenceIndex;
    float sentenceCounter;
    float sentenceTarget;
    Paragraph *currentParagraph;
    BOOL isWaiting;
    id waitingAction;
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
        
        //Scan all the files in xmls/levels folder and save it into paragraphsData dictionary
        self.paragraphsData = [[XMLHelper shared] loadParagraphFromFolder:@"xmls/levels"];
        
        //Save all the paragraph names
        self.paragraphNames = [self.paragraphsData allKeys];
        
        //Load combination data from Editor_level.xml
        self.paragraphsCombination = [[XMLHelper shared] loadParagraphCombinationWithXML:@"Editor_level"];
        
        //TODO: Create weight look up table for the combinations
        
        currentPhaseIndex = 0;
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
}

-(Level *) selectLevelWithName:(NSString *)levelName
{
    return [self.levelData getLevelByName:levelName];
}

-(id) dropAddthingWithName:(NSString *)objectName atPosition:(CGPoint)position
{
    DUPhysicsObject *addthing = [[[AddthingFactory shared] createWithName:objectName] retain];
    
    addthing.sprite.position = position;
    [self.generatedObjects addObject:addthing];
    //DLog(@"%@", [self.generatedObjects description]);
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
    
    return [self dropAddthingWithName:objectName atPosition:ccp(xPosUnit * num + 5 + xPosUnit/2,600)];
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
                    if (item != NOTHING)
                    {
                        AddthingObject *addthing = [self dropAddthingWithName:item atSlot:i];
                        waitingTime = MAX(waitingTime, addthing.wait);
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
    
    id switchToNextLevelAction = [CCCallFunc actionWithTarget:self selector:@selector(switchToNextLevelEffect)];
    id delay1 = [CCDelayTime actionWithDuration:8];
    id loadParagraphAction = [CCCallFunc actionWithTarget:self selector:@selector(loadCurrentParagraph)];
    id delay2 = [CCDelayTime actionWithDuration:8];
    
    [GAMELAYER runAction:[CCSequence actions:delay1, switchToNextLevelAction, delay2, loadParagraphAction, nil]];
    
}

-(void) switchToNextLevelEffect
{
    [[[HeroManager shared] getHero] rocketPowerup];
    [[[BoardManager shared] getBoard] rocketPowerup];
    
    //Speed up scrolling speed
    [[BackgroundController shared] speedUpWithScale:6 interval:5];
    
    //Play speed line effect
    CCNode *particleNode = [[DUParticleManager shared] createParticleWithName:@"FX_speedline.ccbi" parent:GAMELAYER z:Z_Speedline duration:5 life:1];
    particleNode.position = CGPointZero;
    
    //Show Stage clear text
    [[GameUI shared] showStageClearMessageWithDistance];
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

- (void)dealloc
{
    if ([phasePharagraphs retainCount] > 0)
    {
        [phasePharagraphs release];
    }
    [_levelData release];
    [_paragraphsData release];
    [_paragraphsCombination release];
    [_generatedObjects release];
    [_paragraphNames release];
    [super dealloc];
}
@end
