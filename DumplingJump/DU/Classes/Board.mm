//
//  Board.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Board.h"

@implementation Board
-(id) initBoardWithBoardName:(NSString *)theName position:(CGPoint) pos;
{
    if (self = [super initWithName:@"board"])
    {
        self.sprite = [CCSprite spriteWithSpriteFrameName:theName];
        self.sprite.position = pos;
    
        [self initBoardPhysics];
    }
    return self;
}

-(void) initBoardPhysics
{
    [self createBoardBody];
    [self createBoardJoints];
}

-(void) createBoardBody
{
    b2BodyDef boardDef;
    boardDef.position.Set(self.sprite.position.x/RATIO,self.sprite.position.y/RATIO);
    boardDef.type = b2_dynamicBody;
    boardDef.userData = self;
    
    self.body = WORLD->CreateBody(&boardDef);
    
    b2PolygonShape boardShape;
    boardShape.SetAsBox(self.sprite.boundingBox.size.width/2/RATIO, self.sprite.boundingBox.size.height/2/RATIO);
    
    b2FixtureDef boardFixtureDef;
    
    //TODO: NEED CHANGE TO THE REAL VALUE;
    boardFixtureDef.friction = 10;
    boardFixtureDef.restitution = 0.8;
    boardFixtureDef.density = 10;
    boardFixtureDef.shape = &boardShape;
    
    self.body->CreateFixture(&boardFixtureDef);
}

-(void) createBoardJoints
{
    int plateWidth = self.sprite.boundingBox.size.width;
    b2World *world = [[PhysicsManager sharedPhysicsManager] getWorld];
    b2Body *ground = [[PhysicsManager sharedPhysicsManager] getGround];
    
    b2Vec2 anchor_L = b2Vec2(self.body->GetPosition().x - plateWidth/2/RATIO,
                             self.body->GetPosition().y);
    b2Vec2 ground_L = b2Vec2(self.body->GetPosition().x - plateWidth/2/RATIO,
                             self.body->GetPosition().y - 100);
    b2DistanceJointDef rocketDisJointDef_L;
    rocketDisJointDef_L.Initialize(ground, self.body, ground_L, anchor_L);
    rocketDisJointDef_L.collideConnected = true;
    rocketDisJointDef_L.frequencyHz = 1;
    rocketDisJointDef_L.dampingRatio = 1;
    world->CreateJoint(&rocketDisJointDef_L);
    
    b2Vec2 anchor_R = b2Vec2(self.body->GetPosition().x + plateWidth/2/RATIO,
                             self.body->GetPosition().y);
    b2Vec2 ground_R = b2Vec2(self.body->GetPosition().x + plateWidth/2/RATIO,
                             self.body->GetPosition().y - 100);
    b2DistanceJointDef rocketDisJointDef_R;
    rocketDisJointDef_R.Initialize(ground, self.body, ground_R, anchor_R);
    rocketDisJointDef_R.collideConnected = true;
    rocketDisJointDef_R.frequencyHz = 1;
    rocketDisJointDef_R.dampingRatio = 1;
    world->CreateJoint(&rocketDisJointDef_R);
    
    b2Vec2 anchor_MR = b2Vec2(self.body->GetPosition().x,
                              self.body->GetPosition().y);
    b2Vec2 ground_MR = b2Vec2(self.body->GetPosition().x + (plateWidth/2+100)/RATIO,
                              self.body->GetPosition().y);
    b2DistanceJointDef rocketDisjointDef_MR;
    rocketDisjointDef_MR.Initialize(ground, self.body, ground_MR, anchor_MR);
    rocketDisjointDef_MR.collideConnected = true;
    rocketDisjointDef_MR.frequencyHz = 1;
    rocketDisjointDef_MR.dampingRatio = 1;
    world->CreateJoint(&rocketDisjointDef_MR);
    
    b2Vec2 anchor_LR = b2Vec2(self.body->GetPosition().x,
                              self.body->GetPosition().y);
    b2Vec2 ground_LR = b2Vec2(self.body->GetPosition().x - (plateWidth/2+100)/RATIO,
                              self.body->GetPosition().y);
    b2DistanceJointDef rocketDisjointDef_LR;
    rocketDisjointDef_LR.Initialize(ground, self.body, ground_LR, anchor_LR);
    rocketDisjointDef_LR.collideConnected = true;
    rocketDisjointDef_LR.frequencyHz = 1;
    rocketDisjointDef_LR.dampingRatio = 1;
    world->CreateJoint(&rocketDisjointDef_LR);
}


//-(id) initWithFile:(NSString *)fileName z:(int)zValue
//{
//    if(self = [super init])
//    {
//        boardCostume = [CCSprite spriteWithFile:fileName];
//        boardCostume.position = ccp(160,100);
//        [[[Hub shared] gameLayer] addChild:boardCostume z:zValue];
//        [self initBoard];
//        count = 1;
//    }
//    
//    return self;
//}

-(void) dealloc
{
    [super dealloc];
}

@end
