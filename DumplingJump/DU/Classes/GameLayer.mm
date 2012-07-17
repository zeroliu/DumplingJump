#import "GameLayer.h"
#import "BackgroundManager.h"

@implementation GameLayer

+(CCScene *) scene
{
//	autorelease object.
	CCScene *scene = [CCScene node];
	
//	autorelease object.
	GameLayer *layer = [GameLayer node];

	[scene addChild: layer];
	
	return scene;
}

-(void)update:(ccTime)dt
{
    [bgManager updateBackground];
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
        [self initBackground];
        [self scheduleUpdate];
	}
	return self;
}

-(void) initBackground
{
    bgManager = [[BackgroundManager alloc] initWithLayer:self bgLayers:
                 new BgLayer(1, 0, @"CA_background_1.png",-30),
                 new BgLayer(2, 1, @"CA_background_2.png"),
                 new BgLayer(3, 2, @"CA_background_3.png"),nil
                 ];
    
}

- (void) dealloc
{
	delete world;
	world = NULL;

	[super dealloc];
}
@end
