/obj/machinery/power/diesel_gen_segment
	name = "diesel generator"
	desc = "An old generator from the past, generating large amounts of power, while requiring more fuel and upkeep than modern day power generators. This should probably only be used as a last resort."
	icon = 'icons/obj/machines/diesel_generator.dmi'
	icon_state = "diesel_gen0"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	use_power = NO_POWER_USE

	var/integrity = 100 //The generator's current integrity
	var/core = /obj/machinery/power/diesel_gen_segment/diesel_gen

/obj/machinery/power/diesel_gen_segment/wrench_act(mob/living/user, obj/item/tool)
	..()
	if (integrity < 100)
		integrity += 2
		tool.play_tool_sound(src, 50)
		visible_message("<span class='notice'>[user] hits the generator with a wrench, reparing some of the damage.</span>")
		SyncIntegrity()
	else
		to_chat(user, "<span class='notice'>[src] doesn't need repairs!</span>")
	return TRUE

/obj/machinery/power/diesel_gen_segment/proc/SyncIntegrity()
	for(var/obj/machinery/power/diesel_gen_segment/object in orange(1,src))
		object.integrity = src.integrity

/obj/machinery/power/diesel_gen_segment/diesel_gen

	var/active = FALSE //Whether or not the generator is turned on right now
	var/power_gen = 5000
	var/power_output = 1
	var/consumption_rate = 1 //How many units of diesel are used each cycle
	var/fuel = 250 //The current amount of fuel in the tank
	var/max_fuel = 500 //The max amount of fuel that can be put in the tank
	var/current_heat = 20 //The generator's current heat (20 is roughly room temperature so thats the minimum heat)
	var/max_heat = 500
	var/power_level = 80 //At what % of power the generator is running on

	var/list/connected_segments = list()

	//Temp Variables (Change Laters)
	var/core_segment = /obj/machinery/power/diesel_gen_segment/bottom_middle

	//Sound Stuff
	var/ignition_sound = "sound/machines/diesel_generator/diesel_ignition.ogg"
	var/stall_sound = "sound/machines/diesel_generator/diesel_stall.ogg"
	var/datum/looping_sound/diesel_generator/soundloop

/obj/machinery/power/diesel_gen_segment/diesel_gen/Initialize()
	. = ..()
	soundloop = new(list(src), active)
	RegisterSignal(src, COMSIG_ATOM_EXPOSE_REAGENT, .proc/on_expose_reagent)

/obj/machinery/power/diesel_gen_segment/diesel_gen/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/on_expose_reagent(atom/parent_atom, datum/reagent/exposing_reagent, reac_volume)
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

/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/UseFuel()
	fuel -= consumption_rate

/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ProcessHeat()
	if(power_level > 80 && current_heat < max_heat && active)
		current_heat += (power_level - 80) * 0.25
	if(current_heat > 20)
		if(power_level <= 80 && power_level >= 40)
			current_heat -= (-power_level + 80) * 0.1
		if(power_level < 40 || active == FALSE)
			current_heat -= 4
	else
		current_heat = 20
	if(current_heat >= max_heat)
		current_heat = max_heat
	if(current_heat == 20 && active == FALSE)
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ProcessIntegrity()
	if (current_heat >= 300)
		if (current_heat < 400)
			integrity -= 0.5
		else if (current_heat >= 400 && current_heat < max_heat)
			integrity -= 1
		else if (current_heat == max_heat)
			integrity -= 2
		SyncIntegrity()

/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ToggleGenerator()
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

/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ToggleSoundLoop()
	if (active)
		soundloop.start()
	else
		playsound(src, stall_sound, 60)

/obj/machinery/power/diesel_gen_segment/diesel_gen/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	ToggleGenerator()

/obj/machinery/power/diesel_gen_segment/diesel_gen/process()
	if(active)
		if(fuel <= 0)
			ToggleGenerator()
			return
		UseFuel()
	ProcessHeat()
	ProcessIntegrity()

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
