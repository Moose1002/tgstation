/obj/machinery/power/diesel_gen_segment
	name = "diesel generator"
	desc = "An old generator from the past, generating large amounts of power, while requiring more fuel and upkeep than modern day power generators. This should probably only be used as a last resort."
	icon = 'icons/obj/machines/diesel_generator.dmi'
	icon_state = "diesel_gen0"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	use_power = NO_POWER_USE

	var/integrity = 100 //The generator's current integrity

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
	for(var/obj/machinery/power/diesel_gen_segment/object in orange(2,src))
		object.integrity = src.integrity

/obj/machinery/power/diesel_gen_segment/diesel_gen

	var/active = FALSE //Whether or not the generator is turned on right now
	var/power_gen = 200000 //How many watts of power the generator produces
	var/consumption_rate = 1 //How many units of diesel are used each cycle
	var/fuel_reagent = /datum/reagent/diesel
	var/max_fuel = 500 //The max amount of fuel that can be put in the tank
	var/current_heat = 20 //The generator's current heat (20 is roughly room temperature so thats the minimum heat)
	var/max_heat = 500 //The generator's max possible heat
	var/power_level = 80 //At what % of power the generator is running on
	var/reagent_flags = REFILLABLE //Allows you to fill up the generator's tank with any reagent container

	//Sound Stuff
	var/ignition_sound = "sound/machines/diesel_generator/diesel_ignition.ogg"
	var/stall_sound = "sound/machines/diesel_generator/diesel_stall.ogg"
	var/datum/looping_sound/diesel_generator/soundloop

/obj/machinery/power/diesel_gen_segment/diesel_gen/Initialize()
	. = ..()
	create_reagents(max_fuel, reagent_flags)
	reagents.add_reagent(fuel_reagent, 250) //Adds 250 fuel for testing purposes
	soundloop = new(list(src), active)
	AddComponent(/datum/component/plumbing/simple_demand)
	connect_to_network()

/obj/machinery/power/diesel_gen_segment/diesel_gen/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/port_gen/connect_to_network()
	. = ..()

/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/UseFuel()
	var/list/gen_reagents = reagents.reagent_list
	var/non_fuel_volume //The volume of all non-fuel reagents added together
	for(var/datum/reagent/holder_reagent as anything in gen_reagents)
		if (holder_reagent.type != fuel_reagent)
			non_fuel_volume += holder_reagent.volume
	if(non_fuel_volume > 0) //Rather than running another for loop again to check if there is non-fuel reagents just see if there was any quantity of reagents when you run the earlier loop
		reagents.isolate_reagent(fuel_reagent)
		integrity -= non_fuel_volume * 0.1
		visible_message("<span class='warning'>[src] makes a strange noise. It looks like it might be damaged!</span>")
		ToggleGenerator()
		SyncIntegrity()
		return
	reagents.remove_reagent(fuel_reagent, consumption_rate) //If the only reagent in the tank is Diesel then process fuel like normal

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
	if (current_heat < 300)
		return
	if (current_heat >= 300 && current_heat < 400)
		integrity -= 0.5
	else if (current_heat >= 400 && current_heat < max_heat)
		integrity -= 1
	else if (current_heat == max_heat)
		integrity -= 2
	SyncIntegrity()

/**
 * This is the proc that procces the mixture of gas that is produced when 1 unit of diesel is burned.
 *
 * The values are determined by the following calculations, these calulations are very rough and considering how 1 unit of
 * a reagent seems to be different depending on the reagent container I wouldn't trust anything I write below, but I needed to
 * figure out how many moles the exhaust mixture should have so I made it work.
 *
 * A Space Station 13 soda can holds 30 units of soda.
 * A soda can is 12 fl oz, which is around 354.88 mL. I'm gonna round this up to 360 mL so it's easy to divide.
 * If 30 units of soda is 360 mL, then a unit in Space Station 13 is around 12 mL, which is 0.012 L.
 * If a Liter of diesel is around 850g then 0.012 is around 10.2g of diesel.
 * For this I'm using the formula: C13H28 + 20O2 → 13CO2 + 14H2O as the formula of my combustion reaction.
 * In this formula diesel (C13H28) has a molar mass of around 184.36.
 * So 10.2g of diesel would be 0.0553 mol.
 * Going back to our formula if 1 mol of diesel is 13 mol of CO2 and 14 mol of H2O then based on 0.0553 mol of diesel there
 * would be 0.719 mol CO2 and 0.774 mol H2O.
 * So after all of this chemistry I didn't need need to do I'll use the following values for this gas mixture.
 */
/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ProcessExhaust()
	var/datum/gas_mixture/exhaust = new() //If my math is off let me know
	exhaust.add_gases(/datum/gas/carbon_dioxide, /datum/gas/water_vapor)
	exhaust.gases[/datum/gas/carbon_dioxide][MOLES] = 0.719 * consumption_rate
	exhaust.gases[/datum/gas/water_vapor][MOLES] = 0.774 * consumption_rate
	exhaust.temperature = T20C

	loc.assume_air(exhaust)

/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ToggleGenerator()
	if (active)
		active = FALSE
		visible_message("<span class='notice'>[src] stalls out.</span>")
		soundloop.stop()
		addtimer(CALLBACK(src, .proc/ToggleSoundLoop), 1 SECONDS)
	else if(reagents.get_reagent_amount(fuel_reagent) > 0)
		active = TRUE
		START_PROCESSING(SSmachines, src)
		visible_message("<span class='notice'>[src] roars to life!</span>")
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
		if(reagents.get_reagent_amount(fuel_reagent) <= 0)
			ToggleGenerator()
			return
		UseFuel()
		if(powernet)
			add_avail(power_gen * (power_level * 0.01))
	ProcessHeat()
	ProcessIntegrity()
	ProcessExhaust()

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
