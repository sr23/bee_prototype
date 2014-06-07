//
//  BeeBoid.m
//  beeproto
//
//  Created by Paul on 07/06/2014.
//  Copyright (c) 2014 SR23. All rights reserved.
//

#import "BeeBoid.h"

@interface BeeBoid () {
    CGVector _velocity;
}
@end

@implementation BeeBoid

-(void)setVelocity:(CGVector)velocity {
    _velocity = velocity;
}

-(CGVector)getVelocity {
    return _velocity;
}





@end
