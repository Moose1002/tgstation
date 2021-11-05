/obj/item/conveyor_dispenser
	name = "Rapid Conveyor Dispenser"
	desc = "A device used to rapidly place non-controllable conveyors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rpd"
	worn_icon_state = "RPD"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=75000, /datum/material/glass=37500)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	///Direction of the device we are going to spawn, set up in the UI
	var/conveyor_direction = NORTH
	///Speed of construction conveyors
	var/conveyor_build_speed = 0.5 SECONDS
	/// Bitflags for upgrades
	var/upgrade_flags
	var/matter = 0
	var/max_matter = 100
	var/conveyor_cost = 5

/obj/item/conveyor_dispenser/attack_self(mob/user)
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

/obj/item/conveyor_dispenser/attackby(obj/item/attacking_item, mob/user)
	if(insert_matter(attacking_item, user))
		return TRUE
	return ..()

/obj/item/conveyor_dispenser/pre_attack(atom/target, mob/user)
	if(!isfloorturf(target) || istype(target, /area/shuttle))
		return
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
	if(do_after(user, conveyor_build_speed, target))
		if(!use_resource(conveyor_cost, user))
			return FALSE
		var/obj/machinery/conveyor/auto/new_conveyor = new/obj/machinery/conveyor/auto(target, conveyor_direction)
	return TRUE

/obj/item/conveyor_dispenser/proc/insert_matter(obj/insertable_matter, mob/user)
	if(istype(insertable_matter, /obj/item/stack))
		var/obj/item/stack/insertable_stack = insertable_matter
		var/stack_value = insertable_stack.matter_amount
		var/loaded = FALSE
		if(stack_value <= 0)
			to_chat(user, span_notice("You can't insert [insertable_stack.name] into [src]!"))
			return FALSE
		var/maxsheets = round((max_matter-matter)/stack_value)
		if(maxsheets > 0)
			var/amount_to_use = min(insertable_stack.amount, maxsheets)
			insertable_stack.use(amount_to_use)
			matter += stack_value * amount_to_use
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			to_chat(user, span_notice("You insert [amount_to_use] [insertable_stack.name] sheets into [src]. "))
			loaded = TRUE
		else
			to_chat(user, span_warning("You can't insert any more [insertable_stack.name] sheets into [src]!"))
			return FALSE
		if(loaded)
			to_chat(user, span_notice("[src] now holds [matter]/[max_matter] matter-units."))
		return loaded

/obj/item/conveyor_dispenser/proc/use_resource(amount, mob/user)
	if(matter < amount)
		if(user)
			to_chat(user, span_warning("The \'Low Ammo\' light on the device blinks yellow."))
		return FALSE
	matter -= amount
	return TRUE

