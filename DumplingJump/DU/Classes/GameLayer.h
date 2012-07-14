//
//  GameLayer.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-7-9.
//  Copyright CMU ETC 2012. All rights reserved.
//


#import "cocos2d.h"
#import "Box2D.h"

// HelloWorldLayer
@interface GameLayer : CCLayer
{
	b2World* world;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
