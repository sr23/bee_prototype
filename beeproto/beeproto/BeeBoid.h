//
//  BeeBoid.h
//  beeproto
//
//  Created by Paul on 07/06/2014.
//  Copyright (c) 2014 SR23. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BeeBoid : SKSpriteNode

-(void)setVelocity:(CGVector)velocity;
-(CGVector)getVelocity;

@end
