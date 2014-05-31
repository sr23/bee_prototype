//
//  BeeMyScene.h
//  beeproto
//

//  Copyright (c) 2014 SR23. All rights reserved.
//

/*
 * Game ideas:
 *  * Fly as a swarm rather than single bee
 *    * Invidual bees can be lost and form "health"
 *    * Must have at least one bee to end the level
 *    * Each bee has it's own health - decreases with contact with pollution, instant death from fight with wasp
 *  * Collect pollen from flowers (cute) on the ground or from trees high up
 *    * Possibly do something with actually pollinating flowers - bonus/power ups
 *  * Pollen forms the game's "currency"
 *    * Can be spent on buying more bees or making existing bees stronger
 *    * Can be spent on hive upgrades which will lead to more benefits
 *      * Bee shield
 *      * Resistance to pollution
 *      * Different flying patterns - Arrow shape, line shapes (secret easter egg shapes (SR23))
 *  * Enemies: wasps/hornets, pollution clouds, pesticides, something else
 *    * Hive enemies - mites/beetles
 *  * Levels will have fixed length so that it is possible to reach the end and "return to base"
 */

#import <SpriteKit/SpriteKit.h>

@interface BeeMyScene : SKScene

@end
