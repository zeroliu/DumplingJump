//
//  GameLayer.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-7-9.
//  Copyright CMU ETC 2012. All rights reserved.
//


#import "GameLayer.h"

//Pixel to Meter, for box2D unit transition
#define PTM_RATIO 32


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

-(id) init
{
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
	}
	return self;
}

- (void) dealloc
{
	delete world;
	world = NULL;

	[super dealloc];
}
@end
