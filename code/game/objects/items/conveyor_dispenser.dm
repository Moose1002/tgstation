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
	resistance_flags = FIRE_PROOF
	///Direction of the device we are going to spawn, set up in the UI
	var/conveyor_direction = NORTH
	///Speed of construction conveyors
	var/conveyor_build_speed = 0.5 SECONDS
	///Speed of removal of unwrenched devices
	var/destroy_speed = 0.5 SECONDS
	/// Bitflags for upgrades
	var/upgrade_flags

/obj/item/conveyor_dispenser/attack_self(mob/user)
	. = ..()
	conveyor_direction = turn(conveyor_direction, 90)
	balloon_alert(user, "You rotate the conveyor clockwise")

/obj/item/conveyor_dispenser/pre_attack(atom/target, mob/user)
	if(!isfloorturf(target) || istype(target, /area/shuttle))
		return
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
	if(do_after(user, conveyor_build_speed, target))
		var/obj/machinery/conveyor/auto/new_conveyor = new/obj/machinery/conveyor/auto(target, conveyor_direction)
	return TRUE
