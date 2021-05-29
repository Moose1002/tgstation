/obj/machinery/power/diesel_gen_segment
	name = "diesel generator"
	desc = "An old generator from the past, generating large amounts of power, while requiring more fuel and upkeep than modern day power generators. This should probably only be used as a last resort."
	icon = 'icons/obj/machines/diesel_generator.dmi'
	icon_state = "diesel_gen0"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	use_power = NO_POWER_USE

	///The generator segment's current integrity, get synced to all other segments whenever the value changes
	var/integrity = 100
	///Whether or not the segment you're working on has 1 sheet of iron in place
	var/hasMetal = FALSE

/obj/machinery/power/diesel_gen_segment/wrench_act(mob/living/user, obj/item/tool)
	..()
	if (integrity < 100)
		if (integrity >= 60)
			tool.use_tool(src, user, 10, volume = 50)
			integrity += 2
			visible_message("<span class='notice'>[user] hits the generator with a wrench, repairing some of the damage.</span>")
			SyncIntegrity()
		else
			to_chat(user, "<span class='notice'>[src] looks to damaged for simple wrenching. It looks like you'll have to weld new segments on.</span>")
	else
		to_chat(user, "<span class='notice'>[src] doesn't need repairs!</span>")
	return TRUE

/obj/machinery/power/diesel_gen_segment/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if (integrity < 60)
		if(!hasMetal)
			to_chat(user, "<span class='notice'>The plating is beyond salvaging, it's best to replace the old plating with a fresh iron sheet.</span>")
			return
		if(!tool.tool_start_check(user))
			return
		to_chat(user, "<span class='notice'>You start to add new metal plates to [src]'s plating.</span>")
		if(tool.use_tool(src, user, 40, , volume = 50))
			integrity += 10
			hasMetal = FALSE
			visible_message("<span class='notice'>[user] welds new plating onto the generator, repairing some of the damage.</span>")
			SyncIntegrity()
	else
		if (integrity >= 100)
			to_chat(user, "<span class='notice'>[src] doesn't need any welding, it seems to be in good condition.</span>")
		else
			to_chat(user, "<span class='notice'>[src] doesn't need any welding, just some simple bolt tightening should do the trick.</span>")
	return TRUE

/obj/machinery/power/diesel_gen_segment/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/sheet/iron))
		if(hasMetal)
			to_chat(user, "<span class='notice'>There is already a plate placed in place, you need to weld it to secure it down.</span>")
			return
		if(!W.tool_start_check(user, amount=1))
			return

		to_chat(user, "<span class='notice'>You start to add new metal plates to [src]'s plating.</span>")
		if(W.use_tool(src, user, 20, volume=50, amount=1))
			hasMetal = TRUE
			to_chat(user, "<span class='notice'>You add fresh metal plates to the [src]'s plating'.</span>")
		return
	return TRUE

/obj/machinery/power/diesel_gen_segment/proc/SyncIntegrity()
	for(var/obj/machinery/power/diesel_gen_segment/object in orange(2,src))
		object.integrity = src.integrity

/obj/machinery/power/diesel_gen_segment/diesel_gen

	///Whether or not the generator is turned on right now
	var/active = FALSE
	///How many watts of power the generator produces
	var/power_gen = 200000
	///How many units of diesel are used each cycle
	var/consumption_rate = 1
	///The fuel reagent the generator should run on
	var/fuel_reagent = /datum/reagent/diesel
	///The max amount of reagents that can be put in the tank
	var/max_fuel = 500
	///The generator's current heat (20 is roughly room temperature so thats the minimum heat)
	var/current_heat = 20
	///The generator's max possible heat
	var/max_heat = 500
	///At what % of power the generator is running on
	var/power_level = 80
	//Allows you to fill up the generator's tank with any reagent container
	var/reagent_flags = REFILLABLE

	//Sound Stuff

	///The sound that plays when the generator is turned on
	var/ignition_sound = "sound/machines/diesel_generator/diesel_ignition.ogg"
	///The sound that plays when the generator is turned off, either by hand, or by the generator turning itself off due to a problem
	var/stall_sound = "sound/machines/diesel_generator/diesel_stall.ogg"
	///The generator's soundloop
	var/datum/looping_sound/diesel_generator/soundloop


/obj/machinery/power/diesel_gen_segment/diesel_gen/Initialize()
	. = ..()
	create_reagents(max_fuel, reagent_flags)
	reagents.add_reagent(fuel_reagent, 250) //Adds 250 fuel for testing purposes
	soundloop = new(list(src), FALSE)
	AddComponent(/datum/component/plumbing/simple_demand)
	connect_to_network()
	update_appearance()

/obj/machinery/power/diesel_gen_segment/diesel_gen/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/diesel_gen_segment/diesel_gen/connect_to_network()
	. = ..()

/obj/machinery/power/diesel_gen_segment/diesel_gen/update_overlays()
	. = ..()
	. += generator_update_overlays()

/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/generator_update_overlays()
	. = list()
	if(active)
		. += mutable_appearance("icons/obj/machines/diesel_generator.dmi", "smoke", ABOVE_MOB_LAYER + 0.01)
	else
		. += mutable_appearance("icons/obj/machines/diesel_generator.dmi", "test", ABOVE_MOB_LAYER + 0.01)

/**
 * Handles burning diesel fuel and dealing with non-fuel reagents
 *
 * Checks every reagent in the generator and then isolates just diesel fuel.
 * If a reagent is put into the generator that isn't the correct fuel reagent then the generator "filters" it and lowers the integrity.
 *
 * If the generator doesn't have any non-fuel reagents, then the generator runs like normal.
 */
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

///Handles generator temperature
/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ProcessHeat()

	if(power_level > 80 && current_heat < max_heat && active) //Running the generator at a power level over 80 will increase heat
		current_heat += (power_level - 80) * 0.25
	if(current_heat > 20)
		if(power_level <= 80 && power_level >= 40) //If power level is less than 80 the heat will decrease
			current_heat -= (-power_level + 80) * 0.1
		if(power_level < 40 || !active) //Heat decreases at it's max value when either off or lower than 40, it can't cool down any faster
			current_heat -= 4
	else
		current_heat = 20
	if(current_heat > max_heat)
		current_heat = max_heat
	if(current_heat <= 20 && !active)
		STOP_PROCESSING(SSmachines, src)

///Processes the generator's integrity based on the generator's temperature
/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ProcessIntegrity()

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
/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ProcessGas()
	var/datum/gas_mixture/air_contents = loc.return_air()
	if(!air_contents.has_gas(/datum/gas/oxygen, 1.1 * consumption_rate)) //No, diesel generator's do no run in space
		ToggleGenerator()
		visible_message("<span class='warning'>[src]'s engine grinds to a halt, it seems like it's out of oxygen!</span>")
		return

	air_contents.remove_specific(/datum/gas/oxygen, 1.1 * consumption_rate) //Slowly drain the room of oxygen

	var/datum/gas_mixture/exhaust = new() //If my math is off let me know
	exhaust.add_gases(/datum/gas/carbon_dioxide, /datum/gas/water_vapor)
	exhaust.gases[/datum/gas/carbon_dioxide][MOLES] = 0.719 * consumption_rate
	exhaust.gases[/datum/gas/water_vapor][MOLES] = 0.774 * consumption_rate
	exhaust.temperature = 422.04 //The temperature of the hot exhaust gas. This could make the room a little toasty

	loc.assume_air(exhaust) //Unleash our exhaust gas of mass slippage to the world!!


///Turns the generator either on or off depending on it's condition
/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ToggleGenerator()
	if (active) //If the generator is on, turn it off
		active = FALSE
		visible_message("<span class='notice'>[src] stalls out.</span>")
		soundloop.stop()
		addtimer(CALLBACK(src, .proc/ToggleSoundLoop), 1 SECONDS) //Wait a second for the soundloop to wrap up
	else if(reagents.get_reagent_amount(fuel_reagent) > 0) //If the generator is off, and has fuel, turn it on
		active = TRUE
		START_PROCESSING(SSmachines, src)
		visible_message("<span class='notice'>[src] roars to life!</span>")
		playsound(src, ignition_sound, 60)
		addtimer(CALLBACK(src, .proc/ToggleSoundLoop), 3 SECONDS) //Wait a few seconds for the ignition sound to play
	else //If the fuel doesn't have any fuel, don't do anything
		visible_message("<span class='notice'>[src] doesn't want to start. It seems to be out of fuel.</span>")
	update_appearance()

/obj/machinery/power/diesel_gen_segment/diesel_gen/proc/ToggleSoundLoop()
	if (active)
		soundloop.start()
	else
		playsound(src, stall_sound, 60)

///When the generator is clicked, turn it on or off
/obj/machinery/power/diesel_gen_segment/diesel_gen/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	ToggleGenerator()

/obj/machinery/power/diesel_gen_segment/diesel_gen/process()
	if(active)
		if(reagents.get_reagent_amount(fuel_reagent) <= 0) //Looks like we ran out of fuel, can't run a engine with no fuel!
			ToggleGenerator()
			return
		UseFuel() //Looks like we have fuel, so we'll use it.
		if(powernet)
			add_avail(power_gen * (power_level * 0.01)) //Actually generate power for the station.
		ProcessGas() //Engines take in and let out gasses, lets process those.
	if (current_heat < 300) //Integrity is only lowered if the generator is hot, so if it's not don't worry about processing it.
		ProcessIntegrity()
	ProcessHeat() //If the generator is on and the powerlevel is high we'll heat up, if it's off and/or powerlevel is low we'll cool off

/obj/machinery/power/diesel_gen_segment/bottom_middle
	icon_state = "diesel_gen1"

/obj/machinery/power/diesel_gen_segment/bottom_right
	icon_state = "diesel_gen2"

/**
 * Gives the generator a random year of manufacturing
 *
 * I just wanted to add a little detail to make the generators seem a bit more outdated.
 * Creates a random year between 2005-2025 and then applies it to the description when you examine it
 */
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
