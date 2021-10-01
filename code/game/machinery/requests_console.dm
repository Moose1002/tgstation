/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

GLOBAL_LIST_EMPTY(req_console_assistance)
GLOBAL_LIST_EMPTY(req_console_supplies)
GLOBAL_LIST_EMPTY(req_console_information)
GLOBAL_LIST_EMPTY(allConsoles)
GLOBAL_LIST_EMPTY(req_console_ckey_departments)


#define REQ_SCREEN_MAIN 0
#define REQ_SCREEN_REQ_ASSISTANCE 1
#define REQ_SCREEN_REQ_SUPPLIES 2
#define REQ_SCREEN_RELAY 3
#define REQ_SCREEN_WRITE 4
#define REQ_SCREEN_CHOOSE 5
#define REQ_SCREEN_SENT 6
#define REQ_SCREEN_ERR 7
#define REQ_SCREEN_VIEW_MSGS 8
#define REQ_SCREEN_AUTHENTICATE 9
#define REQ_SCREEN_ANNOUNCE 10

#define REQ_EMERGENCY_SECURITY 1
#define REQ_EMERGENCY_ENGINEERING 2
#define REQ_EMERGENCY_MEDICAL 3

/datum/request_message
	var/id
	var/source
	var/content
	var/priority
	var/creation_time
	var/msg_verified
	var/msg_stamped

/datum/request_message/New(message_id, source, content, priority, creation_time, msg_verified, msg_stamped)
	src.id = message_id
	src.source = source
	src.content = content
	src.priority = priority
	src.creation_time = creation_time
	src.msg_verified = msg_verified
	src.msg_stamped = msg_stamped

/obj/machinery/requests_console
	name = "requests console"
	desc = "A console intended to send requests to different departments on the station."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp0"
	base_icon_state = "req_comp"
	var/department = "Unknown" //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/messages = list() //List of all messages
	var/departmentType = 0 //bitflag
		// 0 = none (not listed, can only replied to)
		// assistance = 1
		// supplies = 2
		// info = 4
		// assistance + supplies = 3
		// assistance + info = 5
		// supplies + info = 6
		// assistance + supplies + info = 7
	var/newmessagepriority = REQ_NO_NEW_MESSAGE
	var/screen = REQ_SCREEN_MAIN
		// 0 = main menu,
		// 1 = req. assistance,
		// 2 = req. supplies
		// 3 = relay information
		// 4 = write msg - not used
		// 5 = choose priority - not used
		// 6 = sent successfully
		// 7 = sent unsuccessfully
		// 8 = view messages
		// 9 = authentication before sending
		// 10 = send announcement
	var/silent = FALSE // set to 1 for it not to beep all the time
	var/hackState = FALSE
	var/announcementConsole = FALSE // FALSE = This console cannot be used to send department announcements, TRUE = This console can send department announcements
	var/open = FALSE // TRUE if open
	var/announceAuth = FALSE //Will be set to 1 when you authenticate yourself for announcements
	var/msgVerified = "" //Will contain the name of the person who verified it
	var/obj/item/stamp/msgStamped //If a message is stamped, this will contain the stamp name
	var/message = ""
	var/to_department = "" //the department which will be receiving the message
	var/priority = REQ_NO_NEW_MESSAGE //Priority of the message being sent
	var/datum/request_message/active_message
	var/obj/item/radio/Radio
	var/emergency //If an emergency has been called by this device. Acts as both a cooldown and lets the responder know where it the emergency was triggered from
	var/receive_ore_updates = FALSE //If ore redemption machines will send an update when it receives new ores.
	max_integrity = 300
	armor = list(MELEE = 70, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 0, RAD = 0, FIRE = 90, ACID = 90)

/obj/machinery/requests_console/directional/north
	dir = SOUTH
	pixel_y = 30

/obj/machinery/requests_console/directional/south
	dir = NORTH
	pixel_y = -30

/obj/machinery/requests_console/directional/east
	dir = WEST
	pixel_x = 30

/obj/machinery/requests_console/directional/west
	dir = EAST
	pixel_x = -30

/obj/machinery/requests_console/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(0)
		return
	set_light(1.4,0.7,"#34D352")//green light

/obj/machinery/requests_console/update_icon_state()
	if(open)
		icon_state="[base_icon_state]_[hackState ? "rewired" : "open"]"
		return ..()
	if(machine_stat & NOPOWER)
		icon_state = "[base_icon_state]_off"
		return ..()

	if(emergency || (newmessagepriority == REQ_EXTREME_MESSAGE_PRIORITY))
		icon_state = "[base_icon_state]3"
		return ..()
	if(newmessagepriority == REQ_HIGH_MESSAGE_PRIORITY)
		icon_state = "[base_icon_state]2"
		return ..()
	if(newmessagepriority == REQ_NORMAL_MESSAGE_PRIORITY)
		icon_state = "[base_icon_state]1"
		return ..()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/machinery/requests_console/Initialize()
	. = ..()
	name = "\improper [department] requests console"
	GLOB.allConsoles += src

	if(departmentType)

		if((departmentType & REQ_DEP_TYPE_ASSISTANCE) && !(department in GLOB.req_console_assistance))
			GLOB.req_console_assistance += department

		if((departmentType & REQ_DEP_TYPE_SUPPLIES) && !(department in GLOB.req_console_supplies))
			GLOB.req_console_supplies += department

		if((departmentType & REQ_DEP_TYPE_INFORMATION) && !(department in GLOB.req_console_information))
			GLOB.req_console_information += department

	GLOB.req_console_ckey_departments[ckey(department)] = department

	Radio = new /obj/item/radio(src)
	Radio.listening = 0

/obj/machinery/requests_console/Destroy()
	QDEL_NULL(Radio)
	GLOB.allConsoles -= src
	return ..()

/obj/machinery/requests_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["writeAnnouncement"])
		var/new_message = reject_bad_text(stripped_input(usr, "Write your message:", "Awaiting Input", "", MAX_MESSAGE_LEN))
		if(new_message)
			message = new_message
			priority = clamp(text2num(href_list["priority"]) || REQ_NORMAL_MESSAGE_PRIORITY, REQ_NORMAL_MESSAGE_PRIORITY, REQ_EXTREME_MESSAGE_PRIORITY)
		else
			message = ""
			announceAuth = FALSE
			screen = REQ_SCREEN_MAIN

	if(href_list["sendAnnouncement"])
		if(!announcementConsole)
			return
		if(!(announceAuth || isAdminGhostAI(usr)))
			return
		if(isliving(usr))
			var/mob/living/L = usr
			message = L.treat_message(message)
		minor_announce(message, "[department] Announcement:", html_encode = FALSE)
		GLOB.news_network.SubmitArticle(message, department, "Station Announcements", null)
		usr.log_talk(message, LOG_SAY, tag="station announcement from [src]")
		message_admins("[ADMIN_LOOKUPFLW(usr)] has made a station announcement from [src] at [AREACOORD(usr)].")
		deadchat_broadcast(" made a station announcement from [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr, message_type=DEADCHAT_ANNOUNCEMENT)
		announceAuth = FALSE
		message = ""
		screen = REQ_SCREEN_MAIN

	if(href_list["emergency"])
		if(!emergency)
			var/radio_freq
			switch(text2num(href_list["emergency"]))
				if(REQ_EMERGENCY_SECURITY) //Security
					radio_freq = FREQ_SECURITY
					emergency = "Security"
				if(REQ_EMERGENCY_ENGINEERING) //Engineering
					radio_freq = FREQ_ENGINEERING
					emergency = "Engineering"
				if(REQ_EMERGENCY_MEDICAL) //Medical
					radio_freq = FREQ_MEDICAL
					emergency = "Medical"
			if(radio_freq)
				Radio.set_frequency(radio_freq)
				Radio.talk_into(src,"[emergency] emergency in [department]!!",radio_freq)
				update_appearance()
				addtimer(CALLBACK(src, .proc/clear_emergency), 5 MINUTES)

	updateUsrDialog()

/obj/machinery/requests_console/say_mod(input, list/message_mods = list())
	if(spantext_char(input, "!", -3))
		return "blares"
	else
		. = ..()

/obj/machinery/requests_console/proc/clear_emergency()
	emergency = null
	update_appearance()

//from message_server.dm: Console.createmessage(data["sender"], data["send_dpt"], data["message"], data["verified"], data["stamped"], data["priority"], data["notify_freq"])
/obj/machinery/requests_console/proc/createmessage(source, source_department, message, msgVerified, msgStamped, priority, radio_freq)
	var/linkedsender

	var/sending = "[message]<br>"
	if(msgVerified)
		sending = "[sending][msgVerified]<br>"
	if(msgStamped)
		sending = "[sending][msgStamped]<br>"

	linkedsender = source_department ? "<a href='?src=[REF(src)];write=[ckey(source_department)]'>[source_department]</a>" : (source || "unknown")

	var/authentic = (msgVerified || msgStamped) && " (Authenticated)"
	var/alert = "Message from [source][authentic]"
	var/silenced = silent
	var/header = "<b>From:</b> [linkedsender] Received: [station_time_timestamp()]<BR>"

	switch(priority)
		if(REQ_NORMAL_MESSAGE_PRIORITY)
			if(newmessagepriority < REQ_NORMAL_MESSAGE_PRIORITY)
				newmessagepriority = REQ_NORMAL_MESSAGE_PRIORITY
				update_appearance()

		if(REQ_HIGH_MESSAGE_PRIORITY)
			header = "<span class='bad'>High Priority</span><BR>[header]"
			alert = "PRIORITY Alert from [source][authentic]"
			if(newmessagepriority < REQ_HIGH_MESSAGE_PRIORITY)
				newmessagepriority = REQ_HIGH_MESSAGE_PRIORITY
				update_appearance()

		if(REQ_EXTREME_MESSAGE_PRIORITY)
			header = "<span class='bad'>!!!Extreme Priority!!!</span><BR>[header]"
			alert = "EXTREME PRIORITY Alert from [source][authentic]"
			silenced = FALSE
			if(newmessagepriority < REQ_EXTREME_MESSAGE_PRIORITY)
				newmessagepriority = REQ_EXTREME_MESSAGE_PRIORITY
				update_appearance()

	var/datum/request_message/RM = new(length(messages), source, message, priority, station_time_timestamp(), msgVerified, msgStamped)
	messages += RM

	//prioritymessages += list("source"=source, "source_department"=source_department, "content"=message, "msgVerified"=msgVerified, "msgStamped"=msgStamped, "priority"= priority, "radio_freq"=radio_freq)

	if(!silenced)
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
		say(alert)

	if(radio_freq)
		Radio.set_frequency(radio_freq)
		Radio.talk_into(src, "[alert]: <i>[message]</i>", radio_freq)

/obj/machinery/requests_console/attackby(obj/item/O, mob/user, params)
	if(O.tool_behaviour == TOOL_CROWBAR)
		if(open)
			to_chat(user, span_notice("You close the maintenance panel."))
			open = FALSE
		else
			to_chat(user, span_notice("You open the maintenance panel."))
			open = TRUE
		update_appearance()
		return
	if(O.tool_behaviour == TOOL_SCREWDRIVER)
		if(open)
			hackState = !hackState
			if(hackState)
				to_chat(user, span_notice("You modify the wiring."))
			else
				to_chat(user, span_notice("You reset the wiring."))
			update_appearance()
		else
			to_chat(user, span_warning("You must open the maintenance panel first!"))
		return

	var/obj/item/card/id/ID = O.GetID()
	if(ID)
		msgVerified = ID
		to_chat(user, span_notice("You scan the ID card into the console."))
		if(screen == REQ_SCREEN_ANNOUNCE)
			if (ACCESS_RC_ANNOUNCE in ID.access)
				announceAuth = TRUE
			else
				announceAuth = FALSE
				to_chat(user, span_warning("You are not authorized to send announcements!"))
			updateUsrDialog()
		return
	if (istype(O, /obj/item/stamp))
		var/obj/item/stamp/message_stamp = O
		msgStamped = message_stamp
		to_chat(user, span_warning("You scan the [message_stamp.name] into the console."))
	return ..()

/obj/machinery/requests_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestsConsole", "[department] Requests Console")
		ui.open()

/obj/machinery/requests_console/ui_data(mob/user)
	var/list/data = list()
	data["department"] = department
	data["silent"] = silent
	data["message"] = message
	data["message_priority"] = priority
	data["recipient_department"] = to_department
	data["active_message"] = active_message

	if(msgVerified)
		data["message_verification"] = msgVerified

	if(msgStamped)
		data["message_stamped"] = msgStamped

	if(active_message)
		data["active_message_id"] = active_message.id
		data["active_message_source"] = active_message.source
		data["active_message_creation_time"] = active_message.creation_time
		data["active_message_content"] = active_message.content
		data["active_message_verified"] = active_message.msg_verified
		data["active_message_stamped"] = active_message.msg_stamped

	data["messages"] = list()
	for (var/message_index = messages.len to 1 step -1) //Sort by the most recently sent message
		var/datum/request_message/message = messages[message_index]
		data["messages"] += list(list(
			"id" = message.id,
			"source" = message.source,
			"creation_time" = message.creation_time,
			"content" = message.content,
			"priority" = message.priority
		))

	return data

/obj/machinery/requests_console/ui_static_data(mob/user)
	var/list/data = list()
	data["assistance_departments"] = GLOB.req_console_assistance
	data["supplies_departments"] = GLOB.req_console_supplies
	data["announcement_console"] = announcementConsole

	return data

/obj/machinery/requests_console/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("silence")
			silent = !silent
			return TRUE
		if("set_message")
			message = params["message"]
			return TRUE
		if("set_message_department")
			to_department = params["department"]
			return TRUE
		if("set_message_priority")
			priority = params["priority"]
			return TRUE
		if("exit_message")
			active_message = null
			return TRUE
		if("open_message")
			var/id = text2num(params["id"])
			for(var/datum/request_message/RM in messages)
				if(RM.id == id)
					active_message = RM

			return TRUE
		if("delete_message")
			var/id = text2num(params["id"])
			for(var/datum/request_message/RM in messages)
				if(RM.id == id)
					messages -= RM
					active_message = null

			return TRUE
		if("send_message")
			if(!to_department)
				return
			if(!priority)
				return
			if(!message)
				return

			var/radio_freq
			switch(ckey(to_department))
				if("bridge")
					radio_freq = FREQ_COMMAND
				if("medbay")
					radio_freq = FREQ_MEDICAL
				if("science")
					radio_freq = FREQ_SCIENCE
				if("engineering")
					radio_freq = FREQ_ENGINEERING
				if("security")
					radio_freq = FREQ_SECURITY
				if("cargobay" || "mining")
					radio_freq = FREQ_SUPPLY

			var/datum/signal/subspace/messaging/rc/signal = new(src, list(
			"sender" = department,
			"rec_dpt" = to_department,
			"send_dpt" = department,
			"message" = message,
			"verified" = msgVerified,
			"stamped" = msgStamped,
			"priority" = priority,
			"notify_freq" = radio_freq
			))

			signal.send_to_receivers()

			//Set values back to the defaults
			//to_department = ""
			priority = 0
			message = ""
			msgVerified = ""
			msgStamped = null

	update_icon()


#undef REQ_EMERGENCY_SECURITY
#undef REQ_EMERGENCY_ENGINEERING
#undef REQ_EMERGENCY_MEDICAL

#undef REQ_SCREEN_MAIN
#undef REQ_SCREEN_REQ_ASSISTANCE
#undef REQ_SCREEN_REQ_SUPPLIES
#undef REQ_SCREEN_RELAY
#undef REQ_SCREEN_WRITE
#undef REQ_SCREEN_CHOOSE
#undef REQ_SCREEN_SENT
#undef REQ_SCREEN_ERR
#undef REQ_SCREEN_VIEW_MSGS
#undef REQ_SCREEN_AUTHENTICATE
#undef REQ_SCREEN_ANNOUNCE
