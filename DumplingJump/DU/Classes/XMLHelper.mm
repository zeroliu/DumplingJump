//
//  XMLHelper.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-21.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "XMLHelper.h"
#import "DDXML.h"
#import "Paragraph.h"
#import "AddthingObjectData.h"
#import "DUEffectData.h"
#import "Reaction.h"
#import "Star.h"
#import "Constants.h"
@implementation XMLHelper

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[XMLHelper alloc] init];
    }
    return shared;
}

-(DDXMLDocument *) loadXMLContentFromFile:(NSString *)xmlFilename
{
    DDXMLDocument *xmlDoc;
    NSError *err = nil;
    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:xmlFilename ofType:@"xml" inDirectory:@"xmls"] encoding:NSUTF8StringEncoding error:&err];
    xmlDoc = [[[DDXMLDocument alloc] initWithXMLString:content options:0 error:&err] autorelease];
    if (xmlDoc == nil)
    {
        if (err)
        {
            NSLog(@"error parse to xmldoc, %@", [err localizedDescription]);
        }
    }
    return xmlDoc;
}

-(id) loadAddthingWithXML:(NSString *)fileName
{
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    NSError *err = nil;
    
    NSArray *nodeResults = [xmlDoc nodesForXPath:@"//Item" error:&err];
    if (err)
    {
        NSLog(@"%@", [err localizedDescription]);
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (DDXMLElement *item in nodeResults)
    {
        if (![[[[item nodesForXPath:@"ID" error:&err] objectAtIndex:0] stringValue] isEqualToString:@"0"])
        {
            //NSLog(@"%@",[[[item nodesForXPath:@"ID" error:&err] objectAtIndex:0] stringValue]);
            NSArray *itemProperties = [item children];
            AddthingObjectData *data = [[AddthingObjectData alloc] initEmptyData];
            NSString *addthingName = nil;
            for (DDXMLElement *child in itemProperties)
            {
                if ([[child name] isEqualToString:@"name"])
                {
                    data.name = [child stringValue];
                    addthingName = [child stringValue];
                } else if ([[child name] isEqualToString:@"shape"])
                {
                    data.shape = [child stringValue];
                } else if ([[child name] isEqualToString:@"radius"])
                {
                    data.radius = [[child stringValue] doubleValue] * SCALE_MULTIPLIER / 2;
                } else if ([[child name] isEqualToString:@"width"])
                {
                    data.width = [[child stringValue] doubleValue] * SCALE_MULTIPLIER / 2;
                } else if ([[child name] isEqualToString:@"length"])
                {
                    data.length = [[child stringValue] doubleValue] * SCALE_MULTIPLIER / 2;
                } else if ([[child name] isEqualToString:@"I"])
                {
                    data.i = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"mass"])
                {
                    data.mass = [[child stringValue] doubleValue] * [PHYSICSMANAGER mass_multiplier];
                } else if ([[child name] isEqualToString:@"res"])
                {
                    data.restitution = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"fric"])
                {
                    data.friction = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"gravity"])
                {
                    data.gravity = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"blood"])
                {
                    data.blood = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"react_type"])
                {
                    if (![[child stringValue] isEqualToString:@"Null"])
                    {
                        data.reactionName = [child stringValue];
                    }
                } else if ([[child name] isEqualToString:@"animation"])
                {
                    data.animationName = [child stringValue];
                } else if ([[child name] isEqualToString:@"wait"])
                {
                    data.wait = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"warningTime"])
                {
                    data.warningTime = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"customData"])
                {
                    data.customData = [child stringValue];
                } else if ([[child name] isEqualToString:@"firstTouchSFX"])
                {
                    data.firstTouchSFX = [child stringValue];
                }
            }
            data.spriteName = [NSString stringWithFormat:@"A_%@_1", [addthingName lowercaseString]];
            NSString *animName = [NSString stringWithFormat:@"A_%@", [addthingName lowercaseString]];
            [ANIMATIONMANAGER registerAnimationForName: animName];
            [result setObject:data forKey:addthingName];
            [data release];
        }
    }
    return result;
}

-(id) loadParagraphWithXML: (NSString *)fileName
{
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    return [self loadParagraphWithXMLDoc:xmlDoc];
}

-(id) loadParagraphWithXMLDoc:(DDXMLDocument *)xmlDoc
{
    Paragraph *result = [[[Paragraph alloc] init] autorelease];
    NSError *err;
    
    //Create Node by finding level
    NSArray *nodeResults = [xmlDoc nodesForXPath:@"//level" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    for (DDXMLElement *level in nodeResults)
    {
        if (![[[[level nodesForXPath:@"time" error:&err] objectAtIndex:0] stringValue] isEqualToString:@"0"])
        {
            NSArray *levelArray = [level children];
            float distance = 0;
            NSMutableArray *slotsArray = [NSMutableArray array];
            for (DDXMLElement *child in levelArray)
            {
                //NSLog(@"%@: %@",[child name], [child stringValue]);
                if ([[child name] isEqualToString:@"time"])
                {
                    distance = [[child stringValue] floatValue];
                } else if ([[child name] rangeOfString:@"slot"].location != NSNotFound)
                {
                    int slotNum = [[[child name] substringWithRange:NSMakeRange(4, 1)] intValue];
                    
                    for(int i=[slotsArray count]; i<slotNum-1; i++)
                    {
                        [slotsArray addObject:NOTHING];
                    }
                    [slotsArray addObject:[child stringValue]];
                }
            }
            if ([slotsArray count] < SLOTS_NUM)
            {
                for(int i=[slotsArray count]; i<9; i++)
                {
                    [slotsArray addObject:NOTHING];
                }
            }
            Sentence *thisSentence = [[Sentence alloc] initWithDistance:distance Words:slotsArray];
            [result addSentence:thisSentence];
            [thisSentence release];
        }
    }
    
    return result;
}

-(id) loadParagraphCombinationWithXML: (NSString *)fileName
{
    /*
     *  Data Structure
     *  CombinationArray 
     *      -> PhaseArray (0)
     *          -> SubArray -> tutorial_1, tutorial_2
     *      -> PhaseArray (1)
     *          -> SubArray -> box_1, arrow_1, bonus_1
     *          -> SubArray -> powder_1, box_1
     */
    
    NSMutableArray *combinationArray = [NSMutableArray array];
    
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    NSError *err = nil;
    
    NSArray *nodeResult = [xmlDoc nodesForXPath:@"//Combination" error:&err];
    for (int i=1; i<[nodeResult count]; i++)
    {
        DDXMLDocument *combinationData = [nodeResult objectAtIndex:i];
        
        //Get phase number
        int phase = [[[[combinationData nodesForXPath:@"phase" error:&err] objectAtIndex:0] stringValue] intValue];
        //Get subArray which is at this phase position
        NSMutableArray *phaseArray = nil;
        if ([combinationArray count] > phase)
        {
            phaseArray = [combinationArray objectAtIndex:phase];
        }
        if (phaseArray == nil)
        {
            phaseArray = [NSMutableArray array];
            [combinationArray insertObject: phaseArray atIndex:phase];
        }
        
        NSArray *dataArray = [combinationData children];
        NSMutableArray *subArray = [NSMutableArray array];
        for (DDXMLElement *child in dataArray)
        {
            if ([[child name] rangeOfString:@"step"].location != NSNotFound)
            {
                int step = [[[child name] substringFromIndex:4] intValue];
                [subArray insertObject:[child stringValue] atIndex:step];
            }
        }
        [phaseArray addObject:subArray];
    }
    
    return combinationArray;
}

-(id) loadParagraphFromFolder:(NSString *)folderName
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSString *xmlsPath = [path stringByAppendingPathComponent:folderName];
    
    NSError *error;
    NSArray *xmlfiles = [manager contentsOfDirectoryAtPath:xmlsPath error:&error];
    if (xmlfiles == nil)
    {
        if (error)
        {
            DLog(@"%@", [error localizedDescription]);
        }
        return nil;
    } else
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSString *file in xmlfiles)
        {
            NSString *content = [NSString stringWithContentsOfFile:[xmlsPath stringByAppendingPathComponent:file] encoding:NSUTF8StringEncoding error:&error];
            DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:content options:0 error:&error];
            Paragraph *currentParagraph = [self loadParagraphWithXMLDoc:xmlDoc];
            [dict setObject:currentParagraph forKey:[file stringByDeletingPathExtension]];
            [xmlDoc release];
        }
        return dict;
    }
}

-(id) loadEffectWithXML: (NSString *)fileName
{
    NSMutableDictionary *effectDict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    NSError *err = nil;
    
    NSArray *nodeResult = [xmlDoc nodesForXPath:@"//Effect" error:&err];
    for (DDXMLElement *effect in nodeResult)
    {
        DUEffectData *data = [[DUEffectData alloc]initEmptyEffect];

        NSArray *effectArray = [effect children];
        for (DDXMLElement *child in effectArray)
        {
            if ([[child name] isEqualToString:@"name"])
            {
                data.name = [child stringValue];
            } else if ([[child name] isEqualToString:@"animation"])
            {
                data.animationName = [child stringValue];
                [ANIMATIONMANAGER registerAnimationForName:data.animationName speed:1.8f];
            } else if ([[child name] isEqualToString:@"repeat"])
            {
                data.times = [[child stringValue] intValue];
            } else if ([[child name] isEqualToString:@"scale"])
            {
                data.scale = [[child stringValue] intValue];
            } else if ([[child name] isEqualToString:@"sound"])
            {
                data.sound = [child stringValue];
            }
        }
        if (data.name != nil)
        {
            [effectDict setObject:data forKey:data.name];
        }
        [data release];
    }
    
    return effectDict;
}

-(id) loadReactionWithXML: (NSString *)fileName
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    NSError *err = nil;
    
    //Create Node by finding level
    NSArray *nodeResults = [xmlDoc nodesForXPath:@"//react" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    for (DDXMLElement *react in nodeResults)
    {
        if (![[[[react nodesForXPath:@"ID" error:&err] objectAtIndex:0] stringValue] isEqualToString:@"0"])
        {
            Reaction *theReaction = [[Reaction alloc] initEmptyData];
            for (DDXMLElement *child in [react children])
            {
                if ([[child name] isEqualToString:@"react_type"])
                {
                    theReaction.name = [child stringValue];
                } else if ([[child name] isEqualToString:@"reactimage"])
                {
                    theReaction.heroReactAnimationName = [child stringValue];
                    [ANIMATIONMANAGER registerAnimationForName:theReaction.heroReactAnimationName];
                } else if ([[child name] isEqualToString:@"effectimage"])
                {
                    theReaction.effectName = [child stringValue];
                } else if ([[child name] isEqualToString:@"statetime"])
                {
                    theReaction.reactionLasting = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"react_hero"])
                {
                    theReaction.reactHeroSelectorName = [child stringValue];
                } else if ([[child name] isEqualToString:@"react_hero_param"])
                {
                    theReaction.reactHeroSelectorParam = [child stringValue];
                } else if ([[child name] isEqualToString:@"trigger_clean_hero"])
                {
                    theReaction.triggerCleanHero = [[child stringValue] intValue];
                } else if ([[child name] isEqualToString:@"trigger_clean_board"])
                {
                    theReaction.triggerCleanBoard = [[child stringValue] intValue];
                } else if ([[child name] isEqualToString:@"react_item"])
                {
                    theReaction.reactWorldSelectorName = [child stringValue];
                } else if ([[child name] isEqualToString:@"trigger_clean_item"])
                {
                    theReaction.triggerCleanWorld = [[child stringValue] intValue];
                } else if ([[child name] isEqualToString:@"react_time"])
                {
                    theReaction.reactTimeSelectorName = [child stringValue];
                } else if ([[child name] isEqualToString:@"trigger_react_time"])
                {
                    theReaction.reactTime = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"trigger_clean_time"])
                {
                    theReaction.cleanTime = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"type"])
                {
                    theReaction.type = [child stringValue];
                }
            }
            [dict setObject:theReaction forKey:theReaction.name];
            [theReaction release];
        }
    }
    
    return dict;
}

-(id) loadStarDataWithXML: (NSString *)fileName
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    NSError *err = nil;
    
    //Create Node by finding level
    NSArray *nodeResults = [xmlDoc nodesForXPath:@"//Line" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    
    Star *currentStar = nil;
    int lineWidth = 0;
    int lineCounter = 0;
    NSString *currentStarName;
    
    for (DDXMLElement *line in nodeResults)
    {
        if ([line attributeForName:@"name"] != nil)
        {
            //DLog(@"%@", [line attributeForName:@"name"]);
            currentStarName = [[line attributeForName:@"name"] stringValue];
            currentStar = [[Star alloc] initEmptyStar];
            currentStar.name = [currentStarName retain];
            lineWidth = 0;
            lineCounter = 0;
        } else
        {
            NSArray *slots = [line children];
            for (DDXMLElement *slot in slots)
            {
                int slotNum = [[[slot name] substringFromIndex:4] intValue] - 1;
                [[currentStar.starLines objectAtIndex:lineCounter] replaceObjectAtIndex:slotNum withObject:@"O"];
                lineWidth = max(slotNum, lineWidth);
            }
            
            lineCounter ++;
            if (lineCounter == 9)
            {
                currentStar.width = lineWidth;
                [dict setObject:currentStar forKey:currentStarName];
            }
        }
    }
    
    if (currentStar != nil)
    {
        [currentStar release];
    }
    
    return dict;
}


-(id) loadEquipmentDataWithXML: (NSString *)fileName
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [[self loadXMLContentFromFile:fileName] retain];
    NSError *err = nil;
    
    //Create Node by finding level
    NSArray *nodeResults = [xmlDoc nodesForXPath:@"//Item" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    
    for (DDXMLElement *item in nodeResults)
    {
        NSString *itemName = [[[item nodesForXPath:@"name" error:&err] objectAtIndex:0] stringValue];
        //Skip the header
        if (! [itemName isEqualToString:@"name"])
        {
            NSMutableDictionary *itemDictionary = [NSMutableDictionary dictionary];
            NSArray *itemRawDataArray = [item children];
            for(DDXMLDocument *element in itemRawDataArray)
            {
                [itemDictionary setObject:[element stringValue] forKey:[element name]];
            }
            [dict setObject:itemDictionary forKey:itemName];
        }
    }
    [xmlDoc release];
    
    return dict;
}

-(id) loadUserDataWithXML: (NSString *)fileName
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [[self loadXMLContentFromFile:fileName] retain];
    NSError *err = nil;
    
    //Create Node by finding level
    DDXMLElement *nodeResult = [[xmlDoc nodesForXPath:@"//data" error:&err] objectAtIndex:1];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    
    NSArray *datas = [nodeResult children];
    
    for (DDXMLElement *element in datas)
    {
        [dict setObject:[element stringValue] forKey:[element name]];
    }
    [xmlDoc release];
    return dict;
}

-(id) loadCollisionDataWithXML: (NSString *)fileName
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [[self loadXMLContentFromFile:fileName] retain];
    NSError *err = nil;
    
    NSArray *collisionDatas = [xmlDoc nodesForXPath:@"//data" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    
    for (DDXMLDocument *collisionElement in collisionDatas)
    {
        NSString *name = [[[collisionElement nodesForXPath:@"name" error:&err] objectAtIndex:0] stringValue];
        if (![name isEqualToString:@"current status"])
        {
            NSArray *datas = [collisionElement children];
            NSMutableDictionary *reactionDictionary = [NSMutableDictionary dictionaryWithCapacity:[datas count]];
            for (DDXMLElement *element in datas)
            {
                if (![[element name] isEqualToString:@"name"])
                {
                    [reactionDictionary setObject:[element stringValue] forKey:[element name]];
                }
            }
            [dict setObject:reactionDictionary forKey:name];
            
        }
    }
    [xmlDoc release];
    return dict;
}

-(id) loadUserAchievementData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [[self loadXMLContentFromFile:@"Editor_userAchievementData"] retain];
    NSError *err = nil;
    
    NSArray *achievementsDatas = [xmlDoc nodesForXPath:@"//data" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    
    for (DDXMLDocument *achievementElement in achievementsDatas)
    {
        NSString *achievementID = [[[achievementElement nodesForXPath:@"achievementID" error:&err] objectAtIndex:0] stringValue];
        NSString *groupID = [[[achievementElement nodesForXPath:@"groupID" error:&err] objectAtIndex:0] stringValue];
        NSString *status = [[[achievementElement nodesForXPath:@"hasPassed" error:&err] objectAtIndex:0] stringValue];
        
        
        if (![achievementID isEqualToString:@"AchievementID"] && ![groupID isEqualToString:@"GroupID"])
        {
            [dict setObject:status forKey:[NSString stringWithFormat:@"%@-%@", groupID, achievementID]];
        }
    }
    [xmlDoc release];
    return dict;
}

-(id) loadAchievementData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [[self loadXMLContentFromFile:@"Editor_achievement"] retain];
    NSError *err = nil;
    
    NSArray *achievementsDatas = [xmlDoc nodesForXPath:@"//Achievement" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    
    for (DDXMLDocument *achievementElement in achievementsDatas)
    {
        NSString *achievementID = [[[achievementElement nodesForXPath:@"id" error:&err] objectAtIndex:0] stringValue];
        NSString *groupID = [[[achievementElement nodesForXPath:@"group" error:&err] objectAtIndex:0] stringValue];
        
        if (![achievementID isEqualToString:@"id"] && ![groupID isEqualToString:@"group"])
        {
            NSArray *datas = [achievementElement children];
            NSMutableDictionary *achievementDictionary = [NSMutableDictionary dictionaryWithCapacity:[datas count]];
            for (DDXMLElement *element in datas)
            {
                [achievementDictionary setObject:[element stringValue] forKey:[element name]];
            }
            [dict setObject:achievementDictionary forKey:[NSString stringWithFormat:@"%@-%@", groupID, achievementID]];
        }
    }
    [xmlDoc release];
    return dict;
}

-(id) loadBackgroundData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [[self loadXMLContentFromFile:@"Editor_background"] retain];
    NSError *err = nil;

    NSArray *backgroundDatas = [xmlDoc nodesForXPath:@"//background" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    
    for (DDXMLDocument *backgroundElement in backgroundDatas)
    {
        if ([[[[backgroundElement nodesForXPath:@"end" error:&err] objectAtIndex:0] stringValue] isEqualToString:@"end"])
        {
            NSString *stageNum = [[[backgroundElement nodesForXPath:@"stage" error:&err] objectAtIndex:0] stringValue];
            NSArray *datas = [backgroundElement children];
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:[datas count]];
            for (DDXMLElement *element in datas)
            {
                if (![[element name] isEqualToString:@"end"])
                {
                    [dataDictionary setObject:[element stringValue] forKey:[element name]];
                }
            }
            [dict setObject:dataDictionary forKey:stageNum];
        }
    }
    [xmlDoc release];
    return dict;
}

-(id) loadBackgroundObjectData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [[self loadXMLContentFromFile:@"Editor_background_object"] retain];
    NSError *err = nil;
    
    NSArray *objectDatas = [xmlDoc nodesForXPath:@"//object" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    
    for (DDXMLDocument *objectElement in objectDatas)
    {
        if ([[[[objectElement nodesForXPath:@"end" error:&err] objectAtIndex:0] stringValue] isEqualToString:@"end"])
        {
            NSString *stageNum = [[[objectElement nodesForXPath:@"stage" error:&err] objectAtIndex:0] stringValue];
            NSArray *datas = [objectElement children];
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:[datas count]];
            for (DDXMLElement *element in datas)
            {
                if (![[element name] isEqualToString:@"end"])
                {
                    [dataDictionary setObject:[element stringValue] forKey:[element name]];
                }
            }
            
            NSMutableArray *objectDataArray = [dict objectForKey:stageNum];
            if (objectDataArray == nil)
            {
                objectDataArray = [NSMutableArray array];
                [dict setObject:objectDataArray forKey:stageNum];
            }
            [objectDataArray addObject:dataDictionary];
        }
    }
    [xmlDoc release];
    return dict;
}

-(id) loadIAPData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [[self loadXMLContentFromFile:@"Editor_iap"] retain];
    NSError *err = nil;
    
    NSArray *objectDatas = [xmlDoc nodesForXPath:@"//item" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    
    for (DDXMLDocument *objectElement in objectDatas)
    {
        if ([[[[objectElement nodesForXPath:@"end" error:&err] objectAtIndex:0] stringValue] isEqualToString:@"end"])
        {
            NSString *category = [[[objectElement nodesForXPath:@"category" error:&err] objectAtIndex:0] stringValue];
            
            NSArray *datas = [objectElement children];
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:[datas count]];
            for (DDXMLElement *element in datas)
            {
                if (![[element name] isEqualToString:@"end"])
                {
                    [dataDictionary setObject:[element stringValue] forKey:[element name]];
                }
            }
            
            NSMutableArray *objectDataArray = [dict objectForKey:category];
            if (objectDataArray == nil)
            {
                objectDataArray = [NSMutableArray array];
                [dict setObject:objectDataArray forKey:category];
            }
            
            [objectDataArray addObject:dataDictionary];
        }
    }
    [xmlDoc release];
    return dict;
}

@end
