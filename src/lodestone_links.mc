function load {
	scoreboard objectives add lodeLinks.i dummy
	scoreboard objectives add lodeLinks.id dummy

	execute if data storage lodestone_links:rom {enable:{lodestone_links:1b}} run function lodestone_links:clock_1s
	execute if data storage lodestone_links:rom {enable:{lodestone_links:0b}} run schedule clear lodestone_links:clock_1s
	execute unless data storage lodestone_links:rom enable.lodestone_links run function lodestone_links:enable
}

function disable {
	data modify storage lodestone_links:rom enable.lodestone_links set value 0b
}
function enable {
	data modify storage lodestone_links:rom enable.lodestone_links set value 1b
}

predicate random {
  "condition": "minecraft:random_chance",
  "chance": 0.1
}

blocks fence_blocks {
	minecraft:acacia_fence
	minecraft:birch_fence
	minecraft:chain
	minecraft:crimson_fence
	minecraft:dark_oak_fence
	minecraft:iron_bars
	minecraft:jungle_fence
	minecraft:lightning_rod
	minecraft:nether_brick_fence
	minecraft:oak_fence
	minecraft:spruce_fence
	minecraft:warped_fence
}

blocks pillar_blocks {
	minecraft:andesite_wall
	minecraft:blackstone_wall
	minecraft:brick_wall
	minecraft:cobblestone_wall
	minecraft:diorite_wall
	minecraft:end_stone_brick_wall
	minecraft:granite_wall
	minecraft:grimstone_brick_wall
	minecraft:grimstone_tile_wall
	minecraft:grimstone_wall
	minecraft:mossy_cobblestone_wall
	minecraft:mossy_stone_brick_wall
	minecraft:nether_brick_wall
	minecraft:polished_blackstone_brick_wall
	minecraft:polished_blackstone_wall
	minecraft:polished_grimstone_wall
	minecraft:prismarine_wall
	minecraft:red_nether_brick_wall
	minecraft:red_sandstone_wall
	minecraft:sandstone_wall
	minecraft:stone_brick_wall
}

blocks pane_blocks {
	minecraft:black_stained_glass_pane
	minecraft:blue_stained_glass_pane
	minecraft:brown_stained_glass_pane
	minecraft:chain
	minecraft:cyan_stained_glass_pane
	minecraft:end_rod
	minecraft:glass_pane
	minecraft:gray_stained_glass_pane
	minecraft:green_stained_glass_pane
	minecraft:iron_bars
	minecraft:light_blue_stained_glass_pane
	minecraft:light_gray_stained_glass_pane
	minecraft:lightning_rod
	minecraft:lime_stained_glass_pane
	minecraft:magenta_stained_glass_pane
	minecraft:orange_stained_glass_pane
	minecraft:pink_stained_glass_pane
	minecraft:purple_stained_glass_pane
	minecraft:red_stained_glass_pane
	minecraft:white_stained_glass_pane
	minecraft:yellow_stained_glass_pane
}

function clock_1s {
	# Tag eyes of ender with we.ender_eye
	execute as @e[type=item,tag=!lodestone_links.checked] run {
		execute if entity @s[nbt={Item:{id:"minecraft:compass",Count:1b,tag:{LodestoneTracked:1b}}}] if data entity @s Item.tag.LodestonePos run tag @s add lodestone_links.compass
		tag @s add lodestone_links.checked
	}

	# Execute as checking compass items
	execute as @e[type=item,tag=lodestone_links.compass,tag=lodestone_links.checking] run {
		# If this lodestone link has a functional landing pad, construct it
		execute (if entity @s[tag=lodestone_links.build] at @s align xyz positioned ~.5 ~ ~.5) {
			tag @s remove lodestone_links.checking
			tag @s remove lodestone_links.build
			tp @s ~ ~ ~
			data modify entity @s Motion set value [0.0d,0.0d,0.0d]
			data modify entity @s PickupDelay set value 32767
			data modify entity @s Age set value -32768
			data modify entity @s Item.tag.CustomModelData set value 1
			execute store result entity @s Air short 1 run time query gametime

			<%config.moving_particle_circle('end_rod', {r:0.2, x:0, y:0.1, z:0}, {r:0.1, x:0, y:0, z:0}, 45)%>
			playsound minecraft:entity.ender_dragon.hurt master @a ~ ~ ~ 1 0.1

			execute as @e[type=item,tag=lodestone_links.compass,limit=1,distance=..1] at @s run {
				tag @s remove lodestone_links.compass
				tag @s add lodestone_links.warp
			}
		} else execute(at @s){
			tag @s remove lodestone_links.checking
			tag @s remove lodestone_links.compass
			playsound minecraft:block.beacon.deactivate block @a ~ ~ ~ 1 2
			particle minecraft:enchanted_hit ~ ~.2 ~ 0 0 0 0.2 10 force
		}
	}

	# Execute as checking lodestone link items
	execute as @e[type=item,tag=lodestone_links.warp,tag=lodestone_links.checking_old] run {
		execute (if entity @s[tag=lodestone_links.successful]) {
			tag @s remove lodestone_links.successful
			tag @s remove lodestone_links.checking_old
			# Successfull teleportation effects
			playsound mythos:lodestone_link.transport block @a ~ ~ ~ 4 1
			LOOP(10,i){
				<%config.moving_particle_circle('end_rod', {r:1, x:0, y:0, z:0}, {r:0, x:0, y:0.1+(i*0.1), z:0}, 32)%>
			}
			LOOP(10,i){
				<%config.moving_particle_circle('end_rod', {r:0.5, x:0, y:0, z:0}, {r:0, x:0, y:0.1+(i*0.2), z:0}, 32)%>
			}
		} else execute (at @s) {
			tag @s remove lodestone_links.checking_old
			# Break beacon warp because it is no longer valid
			tp @s ~ ~1.8 ~
			data modify entity @s PickupDelay set value 0
			data remove entity @s Item.tag.CustomModelData
			execute store result entity @s Air short 1 run time query gametime
			tag @s remove lodestone_links.warp
			<%config.moving_particle_circle('end_rod', {r:0.3, x:0, y:1.9, z:0}, {r:0, x:0, y:-0.25, z:0}, 45)%>
			particle minecraft:explosion ~ ~1.9 ~ 0 0 0 1 0 force
			playsound minecraft:entity.blaze.hurt master @a ~ ~ ~ 1 2
			playsound minecraft:entity.wither.hurt master @a ~ ~ ~ 1 0.1
		}
	}

	# Execute as and at eyes of ender on the ground to check if there are on top of a warp stone construct. If there is one, create a warp stone entity
	execute as @e[type=item,tag=lodestone_links.compass,nbt={OnGround:1b}] at @s unless entity @e[type=item,tag=lodestone_links.warp,distance=..2] positioned ~-2 ~-1 ~-2 if block ~1 ~ ~2 minecraft:diamond_block if block ~2 ~ ~1 minecraft:diamond_block if block ~2 ~ ~3 minecraft:diamond_block if block ~3 ~ ~2 minecraft:diamond_block if block ~ ~ ~2 #lodestone_links:pillar_blocks if block ~1 ~ ~1 #minecraft:slabs if block ~1 ~ ~3 #minecraft:slabs if block ~2 ~ ~ #lodestone_links:pillar_blocks if block ~2 ~ ~4 #lodestone_links:pillar_blocks if block ~3 ~ ~1 #minecraft:slabs if block ~3 ~ ~3 #minecraft:slabs if block ~4 ~ ~2 #lodestone_links:pillar_blocks if block ~ ~1 ~2 #lodestone_links:fence_blocks if block ~2 ~1 ~ #lodestone_links:fence_blocks if block ~2 ~1 ~4 #lodestone_links:fence_blocks if block ~4 ~1 ~2 #lodestone_links:fence_blocks if block ~ ~2 ~2 #lodestone_links:pane_blocks if block ~2 ~2 ~ #lodestone_links:pane_blocks if block ~2 ~2 ~4 #lodestone_links:pane_blocks if block ~4 ~2 ~2 #lodestone_links:pane_blocks if block ~2 ~ ~2 minecraft:beacon align xyz positioned ~2.5 ~1 ~2.5 run {
		# If this dimension is the same as the lodestone's dimension
		data modify storage lodestone_links:ram dim set from entity @s Item.tag.LodestoneDimension
		execute store success score #is_same_dim lodeLinks.i run data modify storage lodestone_links:ram dim set from entity @s Dimension
		execute if score #is_same_dim lodeLinks.i matches 0 run {
			# Check if this lodestone has the landing pad structure built around it
			data modify storage lodestone_links:ram pos set value [0.0d,0.0d,0.0d]
			execute store result storage lodestone_links:ram pos[0] double 1 run data get entity @s Item.tag.LodestonePos.X
			execute store result storage lodestone_links:ram pos[1] double 1 run data get entity @s Item.tag.LodestonePos.Y
			execute store result storage lodestone_links:ram pos[2] double 1 run data get entity @s Item.tag.LodestonePos.Z

			execute store result score @s lodeLinks.id run scoreboard players add #last lodeLinks.id 1
			tag @s add lodestone_links.checking

			scoreboard players set #has_lodestone lodeLinks.i 0
			summon area_effect_cloud ~ ~ ~ {Tags:["lodestone_links.check"],Age:-2,Duration:2}
			execute as @e[type=area_effect_cloud,tag=lodestone_links.check,limit=1,distance=..1] run {
				scoreboard players operation @s lodeLinks.id = #last lodeLinks.id
				data modify entity @s Pos set from storage lodestone_links:ram pos
				execute at @s run {
					# Store the success of forceloading into a score
					execute store success score #is_forceloaded lodeLinks.i run forceload add ~ ~
					# If the lodestone landing pad is constructed properly, set a flag score
					schedule 1t append {
						execute as @e[type=area_effect_cloud,tag=lodestone_links.check] at @s positioned ~-2 ~ ~-2 if block ~1 ~ ~2 minecraft:iron_block if block ~2 ~ ~1 minecraft:iron_block if block ~2 ~ ~2 minecraft:lodestone if block ~2 ~ ~3 minecraft:iron_block if block ~3 ~ ~2 minecraft:iron_block if block ~ ~ ~2 #lodestone_links:fence_blocks if block ~1 ~ ~1 #minecraft:slabs if block ~1 ~ ~3 #minecraft:slabs if block ~2 ~ ~ #lodestone_links:fence_blocks if block ~2 ~ ~4 #lodestone_links:fence_blocks if block ~3 ~ ~1 #minecraft:slabs if block ~3 ~ ~3 #minecraft:slabs if block ~4 ~ ~2 #lodestone_links:fence_blocks if block ~ ~1 ~2 #lodestone_links:pane_blocks if block ~2 ~1 ~ #lodestone_links:pane_blocks if block ~2 ~1 ~4 #lodestone_links:pane_blocks if block ~4 ~1 ~2 #lodestone_links:pane_blocks positioned ~2.5 ~1 ~2.5 run {
							<%config.moving_particle_circle('end_rod', {r:0.2, x:0, y:0.1, z:0}, {r:0.1, x:0, y:0, z:0}, 45)%>
							<%config.moving_particle_circle('end_rod', {r:0.2, x:0, y:0.1, z:0}, {r:0, x:0, y:0.4, z:0}, 32)%>
							<%config.moving_particle_circle('end_rod', {r:0.2, x:0, y:0.1, z:0}, {r:0, x:0, y:0.3, z:0}, 32)%>
							<%config.moving_particle_circle('end_rod', {r:0.2, x:0, y:0.1, z:0}, {r:0, x:0, y:0.2, z:0}, 32)%>
							<%config.moving_particle_circle('end_rod', {r:0.2, x:0, y:0.1, z:0}, {r:0, x:0, y:0.1, z:0}, 32)%>
							scoreboard players operation # lodeLinks.i = @s lodeLinks.id
							execute as @e[type=item,tag=lodestone_links.checking] if score @s lodeLinks.id = # lodeLinks.i run tag @s add lodestone_links.build
							# Only unforceload this chunk if it was not already forceloaded
							execute if score #is_forceloaded lodeLinks.i matches 1.. run forceload remove ~ ~
							# Tick
							schedule function lodestone_links:clock_1s 1t replace
							kill @s
						}
					}
				}
			}
		}
	}

	# Tick logic
	execute as @e[type=item,tag=lodestone_links.warp] at @s run {
		# If the lodestone link's local structure is malformed it must be deconstructed.
		tag @s add break
		execute positioned ~-2 ~-1 ~-2 if block ~1 ~ ~2 minecraft:diamond_block if block ~2 ~ ~1 minecraft:diamond_block if block ~2 ~ ~3 minecraft:diamond_block if block ~3 ~ ~2 minecraft:diamond_block if block ~ ~ ~2 #lodestone_links:pillar_blocks if block ~1 ~ ~1 #minecraft:slabs if block ~1 ~ ~3 #minecraft:slabs if block ~2 ~ ~ #lodestone_links:pillar_blocks if block ~2 ~ ~4 #lodestone_links:pillar_blocks if block ~3 ~ ~1 #minecraft:slabs if block ~3 ~ ~3 #minecraft:slabs if block ~4 ~ ~2 #lodestone_links:pillar_blocks if block ~ ~1 ~2 #lodestone_links:fence_blocks if block ~2 ~1 ~ #lodestone_links:fence_blocks if block ~2 ~1 ~4 #lodestone_links:fence_blocks if block ~4 ~1 ~2 #lodestone_links:fence_blocks if block ~ ~2 ~2 #lodestone_links:pane_blocks if block ~2 ~2 ~ #lodestone_links:pane_blocks if block ~2 ~2 ~4 #lodestone_links:pane_blocks if block ~4 ~2 ~2 #lodestone_links:pane_blocks if block ~2 ~ ~2 minecraft:beacon run tag @s remove break
		execute (if entity @s[tag=break]) {
			tp @s ~ ~1.8 ~
			data modify entity @s PickupDelay set value 0
			data remove entity @s Item.tag.CustomModelData
			execute store result entity @s Air short 1 run time query gametime
			tag @s remove lodestone_links.warp
			<%config.moving_particle_circle('end_rod', {r:0.3, x:0, y:1.9, z:0}, {r:0, x:0, y:-0.25, z:0}, 45)%>
			particle minecraft:explosion ~ ~1.9 ~ 0 0 0 1 0 force
			playsound minecraft:entity.blaze.hurt master @a ~ ~ ~ 1 2
			playsound minecraft:entity.wither.hurt master @a ~ ~ ~ 1 0.1

		# If the structure is not malformed perform usual tick logic
		} else {
			# Effects
			summon minecraft:area_effect_cloud ~ ~.1 ~ {Particle:"minecraft:end_rod",Duration:20,Radius:0.5}
			block {
				name sparks
				execute if predicate lodestone_links:random run {
					playsound minecraft:block.sculk_sensor.clicking block @a ~ ~ ~ 2 2
					LOOP(20,i){
						summon minecraft:area_effect_cloud ~<%config.round(i*0.1, 1000)%> ~<%config.round(1.9+(Math.sin(i)*0.1), 1000)%> ~ {Particle:"minecraft:bubble",Duration:4,Radius:0.01}
					}
					particle minecraft:firework ~ ~1.9 ~ 0 0 0 0.1 4 force
				}
				execute if predicate lodestone_links:random run {
					playsound minecraft:block.sculk_sensor.clicking block @a ~ ~ ~ 2 2
					LOOP(20,i){
						summon minecraft:area_effect_cloud ~<%config.round(i*-0.1, 1000)%> ~<%config.round(1.9+(Math.sin(i)*0.1), 1000)%> ~ {Particle:"minecraft:bubble",Duration:4,Radius:0.01}
					}
					particle minecraft:firework ~ ~1.9 ~ 0 0 0 0.1 4 force
				}
				execute if predicate lodestone_links:random run {
					playsound minecraft:block.sculk_sensor.clicking block @a ~ ~ ~ 2 2
					LOOP(20,i){
						summon minecraft:area_effect_cloud ~ ~<%config.round(1.9+(Math.sin(i)*0.1), 1000)%> ~<%config.round(i*0.1, 1000)%> {Particle:"minecraft:bubble",Duration:4,Radius:0.01}
					}
					particle minecraft:firework ~ ~1.9 ~ 0 0 0 0.1 4 force
				}
				execute if predicate lodestone_links:random run {
					playsound minecraft:block.sculk_sensor.clicking block @a ~ ~ ~ 2 2
					LOOP(20,i){
						summon minecraft:area_effect_cloud ~ ~<%config.round(1.9+(Math.sin(i)*0.1), 1000)%> ~<%config.round(i*-0.1, 1000)%> {Particle:"minecraft:bubble",Duration:4,Radius:0.01}
					}
					particle minecraft:firework ~ ~1.9 ~ 0 0 0 0.1 4 force
				}
			}

			# Teleportation
			# If there is a player within 0.7 blocks of the lodestone link entity prepare teleportation
			execute (if entity @p[distance=..0.7]) {
				playsound minecraft:block.beehive.work block @a ~ ~ ~ 2 0.1
				scoreboard players add @s lodeLinks.i 1
				execute if score @s lodeLinks.i matches 1.. run function lodestone_links:sparks
				execute if score @s lodeLinks.i matches 3.. run {
					<%config.moving_particle_circle('end_rod', {r:1, x:0, y:0, z:0}, {r:0, x:0, y:0.5, z:0}, 90)%>
				}
				execute if score @s lodeLinks.i matches 5.. run {
					xp add @p[distance=..0.7] -1 levels
					function lodestone_links:sparks
					<%config.moving_particle_circle('end_rod', {r:2, x:0, y:-1, z:0}, {r:0, x:0, y:0.5, z:0}, 360)%>
				}
				execute if score @s lodeLinks.i matches 8.. run {
					xp add @p[distance=..0.7] -1 levels
					function lodestone_links:sparks
					<%config.moving_particle_circle('end_rod', {r:3, x:0, y:-1, z:0}, {r:0.1, x:0, y:0.6, z:0}, 360)%>
					summon minecraft:area_effect_cloud ~ ~-0.9 ~ {Particle:"minecraft:end_rod",Duration:20,Radius:4}
				}

				execute if score @s lodeLinks.i matches 1 run playsound mythos:lodestone_link.charge_up block @a ~ ~ ~ 1 1
				execute if score @s lodeLinks.i matches 9 run {

					data modify storage lodestone_links:ram pos set value [0.0d,0.0d,0.0d]
					execute store result storage lodestone_links:ram pos[0] double 1 run data get entity @s Item.tag.LodestonePos.X
					execute store result storage lodestone_links:ram pos[1] double 1 run data get entity @s Item.tag.LodestonePos.Y
					execute store result storage lodestone_links:ram pos[2] double 1 run data get entity @s Item.tag.LodestonePos.Z

					scoreboard players operation #link lodeLinks.id = @s lodeLinks.id
					tag @s add lodestone_links.checking_old
					execute as @p[distance=..0.7] run {
						tag @s add this.player
						scoreboard players operation @s lodeLinks.id = #link lodeLinks.id
					}

					# Check to see whether the landing pad is still valid
					scoreboard players set #has_lodestone lodeLinks.i 0
					summon area_effect_cloud ~ ~ ~ {Tags:["lodestone_links.check"],Age:-2,Duration:2}
					execute as @e[type=area_effect_cloud,tag=lodestone_links.check,limit=1,distance=..1] run {
						scoreboard players operation @s lodeLinks.id = #link lodeLinks.id
						data modify entity @s Pos set from storage lodestone_links:ram pos
						execute at @s run {
							# Store the success of forceloading into a score
							execute store success score #is_forceloaded lodeLinks.i run forceload add ~ ~
							# If the lodestone landing pad is constructed properly, set a flag score
							schedule 1t append {
								execute (as @e[type=area_effect_cloud,tag=lodestone_links.check] at @s positioned ~-2 ~ ~-2 if block ~1 ~ ~2 minecraft:iron_block if block ~2 ~ ~1 minecraft:iron_block if block ~2 ~ ~2 minecraft:lodestone if block ~2 ~ ~3 minecraft:iron_block if block ~3 ~ ~2 minecraft:iron_block if block ~ ~ ~2 #lodestone_links:fence_blocks if block ~1 ~ ~1 #minecraft:slabs if block ~1 ~ ~3 #minecraft:slabs if block ~2 ~ ~ #lodestone_links:fence_blocks if block ~2 ~ ~4 #lodestone_links:fence_blocks if block ~3 ~ ~1 #minecraft:slabs if block ~3 ~ ~3 #minecraft:slabs if block ~4 ~ ~2 #lodestone_links:fence_blocks if block ~ ~1 ~2 #lodestone_links:pane_blocks if block ~2 ~1 ~ #lodestone_links:pane_blocks if block ~2 ~1 ~4 #lodestone_links:pane_blocks if block ~4 ~1 ~2 #lodestone_links:pane_blocks positioned ~2.5 ~1 ~2.5) {
									# Teleport the player if the landing pad is valid
									scoreboard players operation # lodeLinks.i = @s lodeLinks.id
									execute as @e[type=item,tag=lodestone_links.checking_old] if score @s lodeLinks.id = # lodeLinks.i run tag @s add lodestone_links.successful

									execute as @a[tag=this.player] if score @s lodeLinks.id = #link lodeLinks.id run {
										tp @s ~ ~1 ~
										scoreboard players reset @s lodeLinks.id
										advancement grant @s only mythos:overlode
										tag @s remove this.player
									}
									playsound mythos:lodestone_link.transport block @a ~ ~ ~ 4 1
									effect give @a[tag=this.player] minecraft:blindness 3 1 true
									effect give @a[tag=this.player] minecraft:nausea 10 127 true
									<%config.moving_particle_circle('end_rod', {r:0.3, x:0, y:1, z:0}, {r:1, x:0, y:0, z:0}, 1000)%>
									<%config.moving_particle_circle('end_rod', {r:0.3, x:0, y:1, z:0}, {r:0.5, x:0, y:0, z:0}, 500)%>
									<%config.moving_particle_circle('end_rod', {r:0.3, x:0, y:1, z:0}, {r:0.1, x:0, y:0, z:0}, 45)%>

									# Only unforceload this chunk if it was not already forceloaded
									execute if score #is_forceloaded lodeLinks.i matches 1.. run forceload remove ~ ~
									# Tick
									schedule function lodestone_links:clock_1s 1t replace
									kill @s
								} else {
									execute as @a[tag=this.player] if score @s lodeLinks.id = #link lodeLinks.id run {
										scoreboard players reset @s lodeLinks.id
										tag @s remove this.player
									}
								}
							}
						}
					}
				}
			} else {
				# Cancel Teleportation
				scoreboard players set @s lodeLinks.i 0
				stopsound @a[distance=..10] block mythos:lodestone_link.charge_up
				playsound minecraft:block.beehive.work block @a ~ ~ ~ 2 0.1
				playsound minecraft:block.beacon.ambient block @a ~ ~ ~ 1 2
			}
		}
	}

	# Tick this function
	schedule function lodestone_links:clock_1s 1s
}

