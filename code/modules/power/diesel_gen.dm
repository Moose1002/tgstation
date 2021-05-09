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

	var/active = FALSE //Whether or not the generator is turned on right now
	var/power_gen = 5000
	var/power_output = 1
	var/consumption_rate = 1 //How many units of diesel are used each cycle
	var/fuel = 250 //The current amount of fuel in the tank
	var/max_fuel = 500 //The max amount of fuel that can be put in the tank
	var/current_heat = 0 //The generator's current heat
	var/integrity = 100 //The generator's current integrity

	//Sound Stuff
	var/ignition_sound = "sound/machines/diesel_generator/diesel_ignition.ogg"
	var/stall_sound = "sound/machines/diesel_generator/diesel_stall.ogg"
	var/datum/looping_sound/diesel_generator/soundloop

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
	if (fuel + reac_volume > max_fuel)
		visible_message("<span class='notice'>As much [exposing_reagent] is added to the tank as it will hold but the tank overflows!</span>")
		fuel = max_fuel
	else if (fuel + reac_volume == max_fuel)
		visible_message("<span class='notice'>The perfect amount of [exposing_reagent] is added to the tank, without it overflowing. You're filled with satisfaction!</span>")
		fuel += reac_volume
	else
		visible_message("<span class='notice'>[reac_volume] units of [exposing_reagent] is added to the generator's tank.</span>")
		fuel += reac_volume

/obj/machinery/power/diesel_gen/process()
	if(active)
		if(fuel <= 0)
			ToggleGenerator()
			return
		UseFuel()

/obj/machinery/power/diesel_gen/proc/UseFuel()
	fuel -= consumption_rate

/obj/machinery/power/diesel_gen/proc/ToggleGenerator()
	if (active)
		active = FALSE
		visible_message("<span class='notice'>The [src.name] stalls out.</span>")
		soundloop.stop()
		addtimer(CALLBACK(src, .proc/ToggleSoundLoop), 1 SECONDS)
	else if(fuel > 0)
		active = TRUE
		START_PROCESSING(SSmachines, src)
		visible_message("<span class='notice'>The [src.name] roars to life!</span>")
		playsound(src, ignition_sound, 60)
		addtimer(CALLBACK(src, .proc/ToggleSoundLoop), 3 SECONDS)
	else
		visible_message("<span class='notice'>[src] doesn't want to start. It seems to be out of fuel.</span>")

/obj/machinery/power/diesel_gen/proc/ToggleSoundLoop()
	if (active)
		soundloop.start()
	else
		playsound(src, stall_sound, 60)


/obj/machinery/power/diesel_gen/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	ToggleGenerator()

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
