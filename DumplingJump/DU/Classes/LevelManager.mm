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
#import "StarManager.h"
#import "Paragraph.h"

@interface LevelManager()
{
    int currentParagraphIndex;
    int sentenceIndex;
    float sentenceCounter;
    float sentenceTarget;
    Paragraph *currentParagraph;
}

@property (nonatomic, retain) LevelData *levelData;
@property (nonatomic, retain) NSMutableArray *paragraphs;
@end

@implementation LevelManager
@synthesize levelData = _levelData, paragraphs = _paragraphs, generatedObjects = _generatedObjects;

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
        self.paragraphs = [[NSMutableArray alloc] initWithCapacity:2];
        [self.paragraphs addObject:[[NSMutableArray alloc] init]];
        [self.paragraphs addObject:[[NSMutableArray alloc] init]];
        
        self.generatedObjects = [[NSMutableArray alloc] init];
        [self loadParagraphs];
        
    }
    
    return self;
}

-(void) loadParagraphs
{
    //load paragraph from xml file
    int i = 1;
    NSString *levelContent = nil;
    do {
        for (int j=1; j<=2; j++)
        {
            Paragraph *level = [[XMLHelper shared] loadParagraphWithXML:[NSString stringWithFormat:@"level%d_%d",i, j]];
            DLog(@"Paragraph loaded + %d_%d", i, j);
            [[self.paragraphs objectAtIndex:(j-1)] addObject:level];
        }
        
        i++;
        levelContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"CA_level%d",i] ofType:@"xml"]  encoding:NSUTF8StringEncoding error:nil];
    } while (levelContent != nil);
    
    //DLog(@"Paragraph loaded + %d", (i-1));
}

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
    DUPhysicsObject *addthing = [[AddthingFactory shared] createWithName:objectName];
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
    currentParagraph = [[self.paragraphs objectAtIndex:0] objectAtIndex:index];
    currentParagraphIndex = index;
    
}

-(void) loadCurrentParagraph
{
    sentenceCounter = 0;
    sentenceIndex = 0;
    sentenceTarget = 0;
    currentParagraph = [[self.paragraphs objectAtIndex:0] objectAtIndex:currentParagraphIndex];
    
}

-(int) paragraphsCount
{
    return [[self.paragraphs objectAtIndex:0] count];
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
                if ([item rangeOfString:@"star"].location == 0)
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
                currentParagraph = nil;
                [self jumpToNextLevel];
                
            }
        }
    }
}

-(void) jumpToNextLevel
{
    //current paragraph finished
    currentParagraphIndex++;
    if (currentParagraphIndex > [self paragraphsCount] - 1)
    {
        currentParagraphIndex = 2;
    }
    
    [self switchToNextLevelEffect];
    [self performSelector:@selector(loadCurrentParagraph) withObject:nil afterDelay:5];
}

-(void) switchToNextLevelEffect
{
    [[[HeroManager shared] getHero] rocketPowerup];
    [[[BoardManager shared] getBoard] rocketPowerup];
    //Speed up scrolling speed
    [[BackgroundController shared] speedUpWithScale:6 interval:5];
}

-(void) stopCurrentParagraph
{
    currentParagraph = nil;
    currentParagraphIndex = 0;
}

-(void) removeObjectFromList:(DUObject *)myObject
{
    [self.generatedObjects removeObject:myObject];
}

-(void) destroyAllObjects
{
    for (DUPhysicsObject *ob in self.generatedObjects)
    {
        [ob archive];
    }
    [self.generatedObjects removeAllObjects];
}

@end
