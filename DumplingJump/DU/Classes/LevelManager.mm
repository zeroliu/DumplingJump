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

@interface LevelManager()
{
    //int currentParagraphIndex;
    
    int currentPhaseIndex;
    NSMutableArray *phasePharagraphs;
    int sentenceIndex;
    float sentenceCounter;
    float sentenceTarget;
    Paragraph *currentParagraph;
}

@property (nonatomic, retain) LevelData *levelData;
//@property (nonatomic, retain) NSMutableArray *paragraphs;
@property (nonatomic, retain) NSDictionary *paragraphsData;
@property (nonatomic, retain) NSArray *paragraphsCombination;
@end

@implementation LevelManager
@synthesize levelData = _levelData, generatedObjects = _generatedObjects, paragraphsData = _paragraphsData, paragraphsCombination = _paragraphsCombination;

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
        
        //Load combination data from Editor_level.xml
        self.paragraphsCombination = [[XMLHelper shared] loadParagraphCombinationWithXML:@"Editor_level"];
        
        //TODO: Create weight look up table for the combinations
        
        currentPhaseIndex = 0;
    }
    
    return self;
}

/*
-(void) loadParagraphs
{
    //load paragraph from xml file
    int i = 1;
    NSString *levelContent = nil;
    do {
        for (int j=1; j<=2; j++)
        {
            DLog(@"Loading: %d_%d", i, j);
            Paragraph *level = [[XMLHelper shared] loadParagraphWithXML:[NSString stringWithFormat:@"level%d_%d",i, j]];
            DLog(@"Paragraph loaded + %d_%d", i, j);
            [[self.paragraphs objectAtIndex:(j-1)] addObject:level];
        }
        
        i++;
        levelContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%d_1",i] ofType:@"xml"]  encoding:NSUTF8StringEncoding error:nil];
    } while (levelContent != nil);
    
    //DLog(@"Paragraph loaded + %d", (i-1));
}
*/

-(id) levelData
{
    if (_levelData == nil) _levelData = [[LevelData alloc] init];
    return _levelData;
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

-(void) loadParagraphAtIndex:(int) index
{
    sentenceCounter = 0;
    sentenceIndex = 0;
    sentenceTarget = 0;
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
    //return [[self.paragraphs objectAtIndex:0] count];
    return 0;
}

-(void) dropNextAddthing
{
    if (currentParagraph != nil)
    {
        sentenceCounter += DISTANCE_UNIT;
        if (sentenceTarget <= sentenceCounter)
        {
            //Trigger a sentence
            Sentence *mySentence = [currentParagraph getSentenceAtIndex:sentenceIndex];
            for (int i=0; i<SLOTS_NUM; i++)
            {
                NSString *item = [mySentence.words objectAtIndex:i];
                if ([item rangeOfString:@"*"].location == 0)
                {
                    
                    [[StarManager shared] dropStar:item AtSlot:i];
                } else
                {
                    if (item != NOTHING)
                    {
                        [self dropAddthingWithName:item atSlot:i];
                    }
                }
            }
            
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
    [super dealloc];
}
@end
