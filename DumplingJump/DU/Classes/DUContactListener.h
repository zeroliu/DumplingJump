//
//  MyContactListener.h
//  Box2DPong
//
//  Created by Ray Wenderlich on 2/18/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//
#import "DUPhysicsObject.h"
#import <vector>
#import <algorithm>

@protocol DUContactListenerDelegate
@optional
-(void)heroLandOnBoard;
-(void)addthingHitBoard:(DUPhysicsObject *)addthing;
-(void)heroStepOnAddthing:(DUPhysicsObject *)addthing;
@end

struct MyContact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const MyContact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

class DUContactListener : public b2ContactListener {
    
    id<DUContactListenerDelegate> delegate;

public:
    std::vector<MyContact>_contacts;
    
    DUContactListener();
    ~DUContactListener();
    
	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    
};
