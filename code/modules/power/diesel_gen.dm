/obj/machinery/power/diesel_gen
	name = "diesel generator"
	desc = "An old generator from the past, generating large amounts of power, while requiring more fuel and upkeep than modern day power generators. This should probably only be used as a last resort."
	icon = 'icons/obj/machines/diesel_generator.dmi'
	icon_state = "diesel_gen0"
	circuit = /obj/item/circuitboard/machine/diesel_gen
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	layer = ABOVE_ALL_MOB_LAYER

	var/active = FALSE
	var/power_gen = 5000
	var/power_output = 1
	var/consumption = 0
	var/fuel = 0
	var/max_fuel = 500
	var/fuel_name = ""
	var/fuel_path = /obj/item/stack/sheet/mineral/plasma
	var/fuel_left = 0 // How much is left of the sheet
	var/time_per_unit = 260
	var/current_heat = 0
	var/base_icon = "portgen2_0"
	var/datum/looping_sound/generator/soundloop

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED

/obj/machinery/power/diesel_gen/Initialize()
	. = ..()
	soundloop = new(list(src), active)
	RegisterSignal(src, COMSIG_ATOM_EXPOSE_REAGENT, .proc/on_expose_reagent)

/obj/machinery/power/diesel_gen/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/diesel_gen/proc/on_expose_reagent(atom/parent_atom, datum/reagent/exposing_reagent, reac_volume)
	SIGNAL_HANDLER
	if (!istype(exposing_reagent, /datum/reagent/diesel))
		visible_message("<span class='notice'>[src] doesn't run on [exposing_reagent]!</span>")
		return
	if (reac_volume <= 0) //This might be pointless?
		visible_message("<span class='notice'>MEGA TEST!!</span>")
		return
	if (fuel + reac_volume > max_fuel)
		visible_message("<span class='notice'>As much [exposing_reagent] is added to the tank as it will hold but the tank overflows!</span>")
		fuel = max_fuel
	else if (fuel + reac_volume == max_fuel)
		visible_message("<span class='notice'>The perfect amount of [exposing_reagent] is added to the tank, without it overflowing. You're filled with satisfaction!</span>")
		fuel += reac_volume
	else
		visible_message("<span class='notice'>[reac_volume] units of [exposing_reagent] is added to the generator's tank.</span>")
		fuel += reac_volume

/obj/machinery/power/diesel_gen/should_have_node()
	return anchored

/obj/machinery/power/diesel_gen/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/diesel_gen/attackby(obj/item/W, mob/user, params)
	. = ..()


/obj/machinery/power/diesel_gen_segment
	name = "diesel generator"
	desc = "An old generator from the past, generating large amounts of power, while requiring more fuel and upkeep than modern day power generators. This should probably only be used as a last resort."
	icon = 'icons/obj/machines/diesel_generator.dmi'
	icon_state = "diesel_gen0"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER

/obj/machinery/power/diesel_gen_segment/bottom_middle
	icon_state = "diesel_gen1"

/obj/machinery/power/diesel_gen_segment/bottom_right
	icon_state = "diesel_gen2"

/obj/machinery/power/diesel_gen_segment/bottom_right/Initialize()
	. = ..()
	var/year = rand(2005, 2025)
	desc = "The year the generator was made seems to be engraved into the side. It reads [year]."

/obj/machinery/power/diesel_gen_segment/top_left
	icon_state = "diesel_gen3"

	density = FALSE
/obj/machinery/power/diesel_gen_segment/top_middle
	icon_state = "diesel_gen4"
	density = FALSE
/obj/machinery/power/diesel_gen_segment/top_right
	icon_state = "diesel_gen5"
	density = FALSE
