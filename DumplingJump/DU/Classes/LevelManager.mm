//
//  LevelManager.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "LevelManager.h"
#import "AddthingFactory.h"
#import "Paragraph.h"

@interface LevelManager()
{
    int sentenceIndex;
    float sentenceCounter;
    float sentenceTarget;
    Paragraph *currentParagraph;
}

@property (nonatomic, retain) LevelData *levelData;
@property (nonatomic, retain) NSMutableArray *paragraphs;
@end

@implementation LevelManager
@synthesize levelData = _levelData, paragraphs = _paragraphs;

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
        self.paragraphs = [[NSMutableArray alloc] init];
        
        [self loadParagraphs];
        
    }
    
    return self;
}

-(void) loadParagraphs
{
    //load paragraph from xml file
    int i = 1;
    NSString *testContent = nil;
    do {
        Paragraph *test = [[XMLHelper shared] loadParagraphWithXML:[NSString stringWithFormat:@"CA_level%d",i]];
        DLog(@"Paragraph loaded + %d", i);
        [self.paragraphs addObject:test];
        i++;
        testContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"CA_level%d",i] ofType:@"xml"]  encoding:NSUTF8StringEncoding error:nil];
    } while (testContent != nil);
    
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

-(void) dropAddthingWithName:(NSString *)objectName atPosition:(CGPoint)position
{
    DUPhysicsObject *addthing = [[AddthingFactory shared] createWithName:objectName];
    addthing.sprite.position = position;
    [addthing addChildTo:BATCHNODE];
}

-(void) dropAddthingWithName:(NSString *)objectName atSlot:(int) num
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float xPosUnit = (winSize.width-5) / (float)SLOTS_NUM;
    
    [self dropAddthingWithName:objectName atPosition:ccp(xPosUnit * num + 5 + xPosUnit/2,600)];
}

-(void) loadParagraphAtIndex:(int) index
{
    currentParagraph = [self.paragraphs objectAtIndex:index];
    sentenceCounter = 0;
    sentenceIndex = 0;
    sentenceTarget = 0;
}

-(int) paragraphsCount
{
    return [self.paragraphs count];
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
                if (item != NOTHING)
                {
                    [self dropAddthingWithName:item atSlot:i];
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
            }
        }
    }
}

@end
