#import "BackgroundManager.h"

#define SCROLL_SPEED 0.3
#define dy -0.3
#define W 320
#define H 530

@implementation BackgroundManager

-(id)initWithFile:(NSString *)theFileName bgLayers:(BgLayer *)firstLayer, ...;
{
    if(self = [super init])
    {
        //Set parent layer
        fileName = theFileName;
        
        //Set the batchNode
        bgBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.pvr",theFileName]];
        
        //Add background plist to the frame cache
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",theFileName]];
        
        //Create bgLayerArray
        NSMutableArray *newBgLayers = [NSMutableArray array];
        va_list args;
        va_start(args, firstLayer);
        for (BgLayer *arg = firstLayer; arg != nil; arg = va_arg(args, BgLayer *))
        {
            //Set the sprite according to the fileName
            arg->sprite = [CCSprite spriteWithSpriteFrameName:arg->fileName];
            arg->swapSprite = [CCSprite spriteWithSpriteFrameName:arg->fileName];
            
            NSValue *anLayer = [NSValue value:arg withObjCType:@encode(BgLayer)];
            [newBgLayers addObject:anLayer];
        }
        va_end(args);
        
        bgLayerArray = [newBgLayers retain];
        
        [self setUpBackground];
    }
    return self;
}

-(void) setUpBackground
{
    for(NSValue *anObject in bgLayerArray)
    {
        //Load one BgLayer
        BgLayer myLayer;
        [anObject getValue:&myLayer];
        
        //Set the sprite position of background sprite and swapSprite
        myLayer.sprite.position = ccp(W/2,H/2+myLayer.offset);
        [bgBatchNode addChild:myLayer.sprite z:myLayer.z];
        myLayer.swapSprite.position = ccp(W/2,H*3/2+myLayer.offset);
        [bgBatchNode addChild:myLayer.swapSprite z:myLayer.z];
    }
    [[[Hub shared]gameLayer] addChild:bgBatchNode];
}

-(void) updateBackground
{
    for(NSValue *anObject in bgLayerArray)
    {
        BgLayer myLayer;
        [anObject getValue:&myLayer];
        
        myLayer.sprite.position = ccpAdd(myLayer.sprite.position, ccp(0,dy*myLayer.speedScale));
        myLayer.swapSprite.position = ccpAdd(myLayer.swapSprite.position, ccp(0,dy*myLayer.speedScale));
        if(myLayer.sprite.position.y < -H/2) myLayer.sprite.position = ccp(W/2, H*3/2 + dy*myLayer.speedScale);
        if(myLayer.swapSprite.position.y < -H/2) myLayer.swapSprite.position = ccp(W/2, H*3/2 + dy*myLayer.speedScale);
//        NSLog(@"sprite pos y = %f, swapsprite pos y = %g", myLayer.sprite.position.y, myLayer.swapSprite.position.y);
    }
}

@end
