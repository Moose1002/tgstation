//RAPID CONVEYOR BELT DEVICE

/obj/item/construction/rbd
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

///Consumes matter and places a conveyor on the provided open floor tile
/obj/item/construction/rbd/proc/place_conveyor(turf/open/floor/target, mob/user)
	if(!checkResource(conveyor_cost, user))
		return
	if(!do_after(user, conveyor_build_speed, target))
		return
	if(!useResource(conveyor_cost, user))
		return
	activate()
	var/obj/machinery/conveyor/auto/new_conveyor = new/obj/machinery/conveyor/auto(target, conveyor_direction)

/obj/item/construction/rbd/attack_self(mob/user)
	. = ..()
	conveyor_direction = turn(conveyor_direction, -45)
	balloon_alert(user, "facing [dir2text(conveyor_direction)]")

/obj/item/construction/rbd/pre_attack(atom/target, mob/user, params)
	. = ..()
	if(istype(target, /area/shuttle))
		balloon_alert(user, "invalid placement")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!isfloorturf(target))
		balloon_alert(user, "object in the way")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(target == user.loc)
		to_chat(user, span_warning("You cannot place a conveyor belt under yourself!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	place_conveyor(target, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/construction/rbd/pre_attack_secondary(atom/target, mob/living/user, params)
	. = ..()
	if(istype(target, /obj/machinery/conveyor/auto))
		var/obj/machinery/conveyor/auto/conveyor_target = target
		conveyor_target.inverted = !conveyor_target.inverted
		conveyor_target.update_move_direction()
		balloon_alert(user, "direction switched")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
