#import "GameLayer.h"

typedef struct BgLayer {
    BgLayer(int p_z, float p_speedScale, NSString *p_fileName)
    {
        z = p_z;
        speedScale = p_speedScale;
        fileName = p_fileName;
        offset = 0;
    }
    
    BgLayer(int p_z, float p_speedScale, NSString *p_fileName, float p_offset)
    {
        z = p_z;
        speedScale = p_speedScale;
        fileName = p_fileName;
        offset = p_offset;
    }
    
    BgLayer(){}
    
    int z;
    float speedScale;
    NSString *fileName;
    float offset;
    CCSprite *sprite;
    CCSprite *swapSprite;
} BgLayer;

@interface BackgroundManager : CCNode
{
    NSString *fileName;
    CCSpriteBatchNode *bgBatchNode;
    NSArray *bgLayerArray;
}

-(id)initWithFile:(NSString *)theFileName bgLayers:(BgLayer *)layer1, ...;
-(void) updateBackground;

@end
