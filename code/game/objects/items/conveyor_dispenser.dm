/obj/item/construction/conveyor_dispenser
	name = "Rapid Conveyor Dispenser"
	desc = "A device used to rapidly place non-controllable conveyors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rpd"
	worn_icon_state = "RPD"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	matter = 100
	max_matter = 100

	///Direction of the device we are going to spawn, set up in the UI
	var/conveyor_direction = NORTH
	///Speed of construction conveyors
	var/conveyor_build_speed = 0.5 SECONDS
	var/conveyor_cost = 5

/obj/item/construction/conveyor_dispenser/attack_self(mob/user)
	. = ..()
	conveyor_direction = turn(conveyor_direction, 90)
	var/direction_text
	switch(conveyor_direction)
		if(NORTH)
			direction_text = "north"
		if(SOUTH)
			direction_text = "south"
		if(EAST)
			direction_text = "east"
		if(WEST)
			direction_text = "west"

	balloon_alert(user, "facing [direction_text]")

/obj/item/construction/conveyor_dispenser/attackby(obj/item/attacking_item, mob/user)
	if(insert_matter(attacking_item, user))
		return TRUE
	return ..()

/obj/item/construction/conveyor_dispenser/pre_attack(atom/target, mob/user)
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
	if(do_after(user, conveyor_build_speed, target))
		if(!use_resource(conveyor_cost, user))
			return FALSE
		var/obj/machinery/conveyor/auto/new_conveyor = new/obj/machinery/conveyor/auto(target, conveyor_direction)
	return TRUE

/obj/item/construction/conveyor_dispenser/proc/place_conveyor(atom/destination, mob/user)
	if(!checkResource(conveyor_cost, user))
		return FALSE


/obj/item/construction/conveyor_dispenser/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !isfloorturf(target) || istype(target, /area/shuttle))
		return
	place_conveyor(targer, user)
