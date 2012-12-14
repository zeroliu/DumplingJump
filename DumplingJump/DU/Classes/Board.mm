//
//  Board.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Board.h"
#import "GLES-Render.h"
#import "GameModel.h"
@interface Board()
{
    BOOL isUnderMissleEffect;
    float _freq_l;
    float _freq_m;
    float _freq_r;
    float _damp_l;
    float _damp_m;
    float _damp_r;
    
    b2Joint *jointL;
    b2Joint *jointR;
    b2Joint *jointMR;
    b2Joint *jointML;
    
    //CCSprite *engineLeft;
    //CCSprite *engineRight;
    
    float boardWidth;
    
    b2Vec2 directionForce;
}

@end

@implementation Board
@synthesize engineLeft = _engineLeft, engineRight = _engineRight;

-(id) initBoardWithBoardName:(NSString *)theName spriteName:(NSString *)fileName position:(CGPoint) pos leftFreq:(float)freq_l middleFreq:(float)freq_m rightFreq:(float)freq_r leftDamp:(float)damp_l middleDamp:(float)damp_m rightDamp:(float)damp_r
{
    if (self = [super initWithName:theName])
    {
        _freq_l = freq_l;
        _freq_m = freq_m;
        _freq_r = freq_r;
        _damp_l = damp_l;
        _damp_m = damp_m;
        _damp_r = damp_r;
        
        self.sprite = [CCSprite spriteWithSpriteFrameName:fileName];
        self.sprite.position = pos;
        float scaleX = 1.1f*370/2 / self.sprite.boundingBox.size.width * SCALE_MULTIPLIER;
        float scaleY = 1.1f*40/2 / self.sprite.boundingBox.size.height * SCALE_MULTIPLIER;
        
        boardWidth = self.sprite.boundingBox.size.width;

        self.engineLeft = [CCSprite spriteWithSpriteFrameName:@"O_engine_1.png"];
        self.engineRight = [CCSprite spriteWithSpriteFrameName:@"O_engine_1.png"];
        
        self.engineLeft.scale = scaleX;
        self.engineRight.scale = scaleX;
        
        id animation = [ANIMATIONMANAGER getAnimationWithName:ANIM_BROOM];
        
        if(animation != nil)
        {
            [self.engineLeft stopAllActions];
            [self.engineRight stopAllActions];
            id animAction1 = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
            id animAction2 = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
            
            [self.engineLeft runAction:animAction1];
            [self.engineRight runAction:animAction2];
        }
        
        self.engineLeft.position = ccp(100,200);
        self.engineRight.position = ccp(200,200);
        
        [BATCHNODE addChild:self.engineLeft z:Z_Engine];
        [BATCHNODE addChild:self.engineRight z:Z_Engine];
        
        NSLog(@"width: %g",self.sprite.boundingBox.size.width);
        self.sprite.scaleX = scaleX;
        self.sprite.scaleY = scaleY;
        NSLog(@"after scale width: %g",self.sprite.boundingBox.size.width);
        [self initBoardPhysics];
        isUnderMissleEffect = NO;
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
    
    float plateWidth = 370/2*SCALE_MULTIPLIER;
    float plateHeight = 40/2*SCALE_MULTIPLIER;
    
    b2PolygonShape boardShape;
    boardShape.SetAsBox(plateWidth/2/RATIO, plateHeight/2/RATIO);
    
    b2FixtureDef boardFixtureDef;
    
    boardFixtureDef.friction = 0.6f;
    boardFixtureDef.restitution = 0;
    boardFixtureDef.density = 10;
    boardFixtureDef.shape = &boardShape;
    boardFixtureDef.filter.categoryBits = C_BOARD;
    boardFixtureDef.filter.maskBits = C_HERO | C_BOARD | C_ADDTHING;
    self.body->CreateFixture(&boardFixtureDef);
}

-(void) createBoardJoints
{
    b2DistanceJointDef rocketDisJointDef_L;
    b2DistanceJointDef rocketDisJointDef_R;
    b2DistanceJointDef rocketDisjointDef_MR;
    b2DistanceJointDef rocketDisjointDef_ML;
    
    float plateWidth = self.sprite.boundingBox.size.width;
    b2World *world = [[PhysicsManager sharedPhysicsManager] getWorld];
    b2Body *ground = [[PhysicsManager sharedPhysicsManager] getGround];
    
    b2Vec2 anchor_L = b2Vec2(self.body->GetPosition().x - plateWidth/2/RATIO,
                             self.body->GetPosition().y);
    b2Vec2 ground_L = b2Vec2(self.body->GetPosition().x - plateWidth/2/RATIO,
                             self.body->GetPosition().y + 100*SCALE_MULTIPLIER/RATIO);
    
    rocketDisJointDef_L.Initialize(ground, self.body, ground_L, anchor_L);
    rocketDisJointDef_L.collideConnected = true;
    rocketDisJointDef_L.frequencyHz = _freq_l;
    rocketDisJointDef_L.dampingRatio = _damp_l;
    rocketDisJointDef_L.userData = @"rocketDisJointDef_L";
    jointL = world->CreateJoint(&rocketDisJointDef_L);
    
    b2Vec2 anchor_R = b2Vec2(self.body->GetPosition().x + plateWidth/2/RATIO,
                             self.body->GetPosition().y);
    b2Vec2 ground_R = b2Vec2(self.body->GetPosition().x + plateWidth/2/RATIO,
                             self.body->GetPosition().y + 100*SCALE_MULTIPLIER/RATIO);
    
    rocketDisJointDef_R.Initialize(ground, self.body, ground_R, anchor_R);
    rocketDisJointDef_R.collideConnected = true;
    rocketDisJointDef_R.frequencyHz = _freq_r;
    rocketDisJointDef_R.dampingRatio = _damp_r;
    rocketDisJointDef_R.userData = @"rocketDisJointDef_R";
    jointR = world->CreateJoint(&rocketDisJointDef_R);
    
    b2Vec2 anchor_MR = b2Vec2(self.body->GetPosition().x,
                              self.body->GetPosition().y);
    b2Vec2 ground_MR = b2Vec2(self.body->GetPosition().x + (plateWidth/2+50*SCALE_MULTIPLIER)/RATIO,
                              self.body->GetPosition().y);
    
    rocketDisjointDef_MR.Initialize(ground, self.body, ground_MR, anchor_MR);
    rocketDisjointDef_MR.collideConnected = true;
    rocketDisjointDef_MR.frequencyHz = _freq_m;
    rocketDisjointDef_MR.dampingRatio = _damp_m;
    rocketDisjointDef_MR.userData = @"rocketDisJointDef_MR";
    jointMR = world->CreateJoint(&rocketDisjointDef_MR);
    
    b2Vec2 anchor_LR = b2Vec2(self.body->GetPosition().x,
                              self.body->GetPosition().y);
    b2Vec2 ground_LR = b2Vec2(self.body->GetPosition().x - (plateWidth/2+50*SCALE_MULTIPLIER)/RATIO,
                              self.body->GetPosition().y);
    
    rocketDisjointDef_ML.Initialize(ground, self.body, ground_LR, anchor_LR);
    rocketDisjointDef_ML.collideConnected = true;
    rocketDisjointDef_ML.frequencyHz = _freq_m;
    rocketDisjointDef_ML.dampingRatio = _damp_m;
    rocketDisjointDef_ML.userData = @"rocketDisJointDef_ML";
    jointML = world->CreateJoint(&rocketDisjointDef_ML);
}

-(void) missleEffectWithDirection:(int)direction
{
    if (!isUnderMissleEffect)
    {
        b2World *world = [[PhysicsManager sharedPhysicsManager] getWorld];
        isUnderMissleEffect = YES;
        if (direction == 0)
        {
            for ( b2Joint *joint = world->GetJointList(); joint; joint = joint->GetNext() )
            {
                if (dynamic_cast<b2DistanceJoint *>(joint))
                {
                    if ([(NSString *)joint->GetUserData() isEqualToString:@"rocketDisJointDef_L"])
                    {
                        (dynamic_cast<b2DistanceJoint *>(joint))->SetFrequency(0.1f);
                    }
                }
            }
        } else if (direction == 1)
        {
            for ( b2Joint *joint = world->GetJointList(); joint; joint = joint->GetNext() )
            {
                if (dynamic_cast<b2DistanceJoint *>(joint))
                {
                    if ([(NSString *)joint->GetUserData() isEqualToString:@"rocketDisJointDef_R"])
                    {
                        (dynamic_cast<b2DistanceJoint *>(joint))->SetFrequency(0.1f);
                    }
                }
            }
        }
    }
}

-(void) recover
{
    DLog(@"recover");
    b2World *world = [[PhysicsManager sharedPhysicsManager] getWorld];
    isUnderMissleEffect = NO;
    for ( b2Joint *joint = world->GetJointList(); joint; joint = joint->GetNext() )
    {
        if (dynamic_cast<b2DistanceJoint *>(joint))
        {
            if ([(NSString *)joint->GetUserData() isEqualToString:@"rocketDisJointDef_L"])
            {
                (dynamic_cast<b2DistanceJoint *>(joint))->SetFrequency(0.7f);
            }
            if ([(NSString *)joint->GetUserData() isEqualToString:@"rocketDisJointDef_R"])
            {
                (dynamic_cast<b2DistanceJoint *>(joint))->SetFrequency(0.7f);
            }
        }
    }
}

-(void) rocketPowerup
{
    float scaleX = self.sprite.scaleX;
    float scaleY = self.sprite.scaleY;
    
    //Make it not collide with any objects except for the hero
    [self changeCollisionDetection:C_HERO];
    
    //Scale down board
    id scaleUp = [CCScaleTo actionWithDuration:0.3 scaleX:0.8*scaleX scaleY:0.8*scaleY];
    
    //Push board to the middle of the screen
    directionForce = b2Vec2(0, self.body->GetMass()*60);
    
    //Countdown certain amount of time
    float duration = [[POWERUP_DATA objectForKey:@"rocket"] floatValue];
    id delay = [CCDelayTime actionWithDuration: duration];
    
    //Remove pushing force
    id resetDirectionForce = [CCCallBlock actionWithBlock:^
                              {
                                  directionForce = b2Vec2(0, 0);
                              }];
    
    //Reset the hero collision
    id resetCollision = [CCCallBlock actionWithBlock:^
                         {
                             [self resetCollisionDetection];
                         }];
    //Scale down Hero to normal;
    id scaleDown = [CCScaleTo actionWithDuration:0.3 scaleX:scaleX scaleY:scaleY];;
    
    [self.sprite runAction:[CCSequence actions:scaleUp, delay, resetDirectionForce, resetCollision, scaleDown, nil]];
}

-(void) changeCollisionDetection:(uint)maskBits
{
    for (b2Fixture* f = self.body->GetFixtureList(); f; f = f->GetNext())
    {
        b2Filter filter;
        filter = f->GetFilterData();
        filter.maskBits = maskBits;
        f->SetFilterData(filter);
    }
}

-(void) resetCollisionDetection
{
    for (b2Fixture* f = self.body->GetFixtureList(); f; f = f->GetNext())
    {
        b2Filter filter;
        filter = f->GetFilterData();
        filter.maskBits = C_HERO | C_BOARD | C_ADDTHING;
        f->SetFilterData(filter);
    }
}

-(void) updateBoardForce
{
    if (directionForce.x != 0 || directionForce.y != 0)
    {
        self.body->ApplyForce(directionForce, self.body->GetPosition());
    }
}

-(void) updateEnginePosition
{
    if (self.engineLeft != nil && self.engineRight != nil)
    {
        boardWidth = self.sprite.boundingBox.size.width;
        float boardPx = self.body->GetPosition().x * RATIO;
        float boardPy = self.body->GetPosition().y * RATIO;
        float boardAngle = self.body->GetAngle();
        
        float zOffset = -40;
        float xOffset = -20;
        self.engineLeft.position = ccp(boardPx - (boardWidth+xOffset)/2 * cos(boardAngle), zOffset + boardPy - (boardWidth+xOffset)/2* sin(boardAngle));
        self.engineLeft.rotation = -boardAngle;
        
        self.engineRight.position = ccp(boardPx + (boardWidth+xOffset)/2* cos(boardAngle), zOffset + boardPy + (boardWidth+xOffset)/2* sin(boardAngle));
        self.engineRight.rotation = -boardAngle;
    }
}

-(void) cleanEngine
{
    if (self.engineLeft != nil)
    {
        [self.engineLeft removeFromParentAndCleanup:NO];
        //[engineLeft release];
        self.engineLeft = nil;
    }
    
    if (self.engineRight != nil)
    {
        [self.engineRight removeFromParentAndCleanup:NO];
        //[engineRight release];
        self.engineRight = nil;
    }
}

-(void) remove
{
    [self cleanEngine];
    [super remove];
}

-(void) onExit
{
    [self cleanEngine];
}

-(void) deactivate
{
    b2World *world = [[PhysicsManager sharedPhysicsManager] getWorld];
    world->DestroyJoint(jointML);
    world->DestroyJoint(jointMR);
    world->DestroyJoint(jointL);
    world->DestroyJoint(jointR);
    [super deactivate];
}

-(void) dealloc
{
    [_engineLeft release];
    [_engineRight release];
    [super dealloc];
}

@end
