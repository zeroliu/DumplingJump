//
//  BackgroundModel.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"

typedef struct BgLayer {
    BgLayer(int p_z, float p_speedScale, float p_depth, NSString *p_fileName)
    {
        z = p_z;
        speedScale = p_speedScale;
        fileName = p_fileName;
        depth = p_depth;
        offset = 0;
    }
    
    BgLayer(int p_z, float p_speedScale, float p_depth, NSString *p_fileName, float p_offset)
    {
        z = p_z;
        speedScale = p_speedScale;
        depth = p_depth;
        fileName = p_fileName;
        offset = p_offset;
    }
    
    BgLayer(){}
    
    int z; 
    float speedScale;
    float depth;
    NSString *fileName;
    float offset;
    CCSprite *sprite;
    CCSprite *swapSprite;
} BgLayer;

@interface BackgroundModel : CCNode

-(void) addBackgroundWithFileName:(NSString *)theBGSpritesheetFileName bgLayers:(BgLayer *)layer1, ...;
-(NSMutableArray *) getBGArrayByName:(NSString *)theName;
@end
