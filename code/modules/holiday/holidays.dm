/datum/holiday
	///Name of the holiday itself. Visible to players.
	var/name = "If you see this the holiday calendar code is broken"

	///What day of begin_month does the holiday begin on?
	var/begin_day = 1
	///What month does the holiday begin on?
	var/begin_month = 0
	/// What day of end_month does the holiday end? Default of 0 means the holiday lasts a single.
	var/end_day = 0
	/// What month does the holiday end on?
	var/end_month = 0
	/// for christmas neverending, or testing. Forces a holiday to be celebrated.
	var/always_celebrate = FALSE
	/// Held variable to better calculate when certain holidays may fall on, like easter.
	var/current_year = 0
	/// How many years are you offsetting your calculations for begin_day and end_day on. Used for holidays like easter.
	var/year_offset = 0
	///Timezones this holiday is celebrated in (defaults to three timezones spanning a 50 hour window covering all timezones)
	var/list/timezones = list(TIMEZONE_LINT, TIMEZONE_UTC, TIMEZONE_ANYWHERE_ON_EARTH)
	///If this is defined, drones without a default hat will spawn with this one during the holiday; check drones_as_items.dm to see this used
	var/obj/item/drone_hat
	///When this holiday is active, does this prevent mail from arriving to cargo? Try not to use this for longer holidays.
	var/mail_holiday = FALSE

// This proc gets run before the game starts when the holiday is activated. Do festive shit here.
/datum/holiday/proc/celebrate()
	if(mail_holiday)
		SSeconomy.mail_blocked = TRUE
	return

// When the round starts, this proc is ran to get a text message to display to everyone to wish them a happy holiday
/datum/holiday/proc/greet()
	return "Have a happy [name]!"

// Returns special prefixes for the station name on certain days. You wind up with names like "Christmas Object Epsilon". See new_station_name()
/datum/holiday/proc/getStationPrefix()
	//get the first word of the Holiday and use that
	var/i = findtext(name, " ")
	return copytext(name, 1, i)

// Return 1 if this holidy should be celebrated today
/datum/holiday/proc/shouldCelebrate(dd, mm, yyyy, ddd)
	if(always_celebrate)
		return TRUE

	if(!end_day)
		end_day = begin_day
	if(!end_month)
		end_month = begin_month
	if(end_month > begin_month) //holiday spans multiple months in one year
		if(mm == end_month) //in final month
			if(dd <= end_day)
				return TRUE

		else if(mm == begin_month)//in first month
			if(dd >= begin_day)
				return TRUE

		else if(mm in begin_month to end_month) //holiday spans 3+ months and we're in the middle, day doesn't matter at all
			return TRUE

	else if(end_month == begin_month) // starts and stops in same month, simplest case
		if(mm == begin_month && (dd in begin_day to end_day))
			return TRUE

	else // starts in one year, ends in the next
		if(mm >= begin_month && dd >= begin_day) // Holiday ends next year
			return TRUE
		if(mm <= end_month && dd <= end_day) // Holiday started last year
			return TRUE

	return FALSE

// The actual holidays

/datum/holiday/new_year
	name = NEW_YEAR
	begin_day = 31
	begin_month = DECEMBER
	end_day = 2
	end_month = JANUARY
	drone_hat = /obj/item/clothing/head/festive
	mail_holiday = TRUE

/datum/holiday/new_year/getStationPrefix()
	return pick("Party","New","Hangover","Resolution", "Auld")

/datum/holiday/groundhog
	name = "Groundhog Day"
	begin_day = 2
	begin_month = FEBRUARY
	drone_hat = /obj/item/clothing/head/helmet/space/chronos

/datum/holiday/groundhog/getStationPrefix()
	return pick("Deja Vu") //I have been to this place before

/datum/holiday/valentines
	name = VALENTINES
	begin_day = 14
	end_day = 15
	begin_month = FEBRUARY

/datum/holiday/valentines/getStationPrefix()
	return pick("Love","Amore","Single","Smootch","Hug")

/// Garbage DAYYYYY
/// Huh?.... NOOOO
/// *GUNSHOT*
/// AHHHGHHHHHHH
/datum/holiday/garbageday
	name = GARBAGEDAY
	begin_day = 17
	end_day = 17
	begin_month = JUNE

/datum/holiday/birthday
	name = "Birthday of Space Station 13"
	begin_day = 16
	begin_month = FEBRUARY
	drone_hat = /obj/item/clothing/head/festive

/datum/holiday/birthday/greet()
	var/game_age = text2num(time2text(world.timeofday, "YYYY")) - 2003
	var/Fact
	switch(game_age)
		if(16)
			Fact = " SS13 is now old enough to drive!"
		if(18)
			Fact = " SS13 is now legal!"
		if(21)
			Fact = " SS13 can now drink!"
		if(26)
			Fact = " SS13 can now rent a car!"
		if(30)
			Fact = " SS13 can now go home and be a family man!"
		if(35)
			Fact = " SS13 can now run for President of the United States!"
		if(40)
			Fact = " SS13 can now suffer a midlife crisis!"
		if(50)
			Fact = " Happy golden anniversary!"
		if(65)
			Fact = " SS13 can now start thinking about retirement!"
	if(!Fact)
		Fact = " SS13 is now [game_age] years old!"

	return "Say 'Happy Birthday' to Space Station 13, first publicly playable on February 16th, 2003![Fact]"

/datum/holiday/random_kindness
	name = "Random Acts of Kindness Day"
	begin_day = 17
	begin_month = FEBRUARY

/datum/holiday/random_kindness/greet()
	return "Go do some random acts of kindness for a stranger!" //haha yeah right

/datum/holiday/leap
	name = "Leap Day"
	begin_day = 29
	begin_month = FEBRUARY

/datum/holiday/pi
	name = "Pi Day"
	begin_day = 14
	begin_month = MARCH

/datum/holiday/pi/getStationPrefix()
	return pick("Sine","Cosine","Tangent","Secant", "Cosecant", "Cotangent")

/datum/holiday/no_this_is_patrick
	name = "St. Patrick's Day"
	begin_day = 17
	begin_month = MARCH
	drone_hat = /obj/item/clothing/head/soft/green

/datum/holiday/no_this_is_patrick/getStationPrefix()
	return pick("Blarney","Green","Leprechaun","Booze")

/datum/holiday/no_this_is_patrick/greet()
	return "Happy National Inebriation Day!"

/datum/holiday/april_fools
	name = APRIL_FOOLS
	begin_month = APRIL
	begin_day = 1
	end_day = 2

/datum/holiday/april_fools/celebrate()
	. = ..()
	SSjob.set_overflow_role(/datum/job/clown)
	SSticker.login_music = 'sound/ambience/clown.ogg'
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/P = i
		if(P.client)
			P.client.playtitlemusic()

/datum/holiday/spess
	name = "Cosmonautics Day"
	begin_day = 12
	begin_month = APRIL
	drone_hat = /obj/item/clothing/head/syndicatefake

/datum/holiday/spess/greet()
	return "On this day over 600 years ago, Comrade Yuri Gagarin first ventured into space!"

/datum/holiday/fourtwenty
	name = "Four-Twenty"
	begin_day = 20
	begin_month = APRIL

/datum/holiday/fourtwenty/getStationPrefix()
	return pick("Snoop","Blunt","Toke","Dank","Cheech","Chong")

/datum/holiday/tea
	name = "National Tea Day"
	begin_day = 21
	begin_month = APRIL

/datum/holiday/tea/getStationPrefix()
	return pick("Crumpet","Assam","Oolong","Pu-erh","Sweet Tea","Green","Black")

/datum/holiday/earth
	name = "Earth Day"
	begin_day = 22
	begin_month = APRIL

/datum/holiday/labor
	name = "Labor Day"
	begin_day = 1
	begin_month = MAY
	drone_hat = /obj/item/clothing/head/hardhat
	mail_holiday = TRUE

/datum/holiday/firefighter
	name = "Firefighter's Day"
	begin_day = 4
	begin_month = MAY
	drone_hat = /obj/item/clothing/head/hardhat/red

/datum/holiday/firefighter/getStationPrefix()
	return pick("Burning","Blazing","Plasma","Fire")

/datum/holiday/bee
	name = "Bee Day"
	begin_day = 20
	begin_month = MAY
	drone_hat = /obj/item/clothing/mask/animal/rat/bee

/datum/holiday/bee/getStationPrefix()
	return pick("Bee","Honey","Hive","Africanized","Mead","Buzz")

/datum/holiday/summersolstice
	name = "Summer Solstice"
	begin_day = 21
	begin_month = JUNE

/datum/holiday/doctor
	name = "Doctor's Day"
	begin_day = 1
	begin_month = JULY
	drone_hat = /obj/item/clothing/head/nursehat

/datum/holiday/ufo
	name = "UFO Day"
	begin_day = 2
	begin_month = JULY
	drone_hat = /obj/item/clothing/mask/facehugger/dead

/datum/holiday/ufo/getStationPrefix() //Is such a thing even possible?
	return pick("Ayy","Truth","Tsoukalos","Mulder","Scully") //Yes it is!

/datum/holiday/usa
	name = "US Independence Day"
	timezones = list(TIMEZONE_EDT, TIMEZONE_CDT, TIMEZONE_MDT, TIMEZONE_MST, TIMEZONE_PDT, TIMEZONE_AKDT, TIMEZONE_HDT, TIMEZONE_HST)
	begin_day = 4
	begin_month = JULY
	mail_holiday = TRUE

/datum/holiday/usa/getStationPrefix()
	return pick("Independent","American","Burger","Bald Eagle","Star-Spangled", "Fireworks")

/datum/holiday/nz
	name = "Waitangi Day"
	timezones = list(TIMEZONE_NZDT, TIMEZONE_CHADT)
	begin_day = 6
	begin_month = FEBRUARY

/datum/holiday/nz/getStationPrefix()
	return pick("Aotearoa","Kiwi","Fish 'n' Chips","Kākāpō","Southern Cross")

/datum/holiday/nz/greet()
	var/nz_age = text2num(time2text(world.timeofday, "YYYY")) - 1840
	return "On this day [nz_age] years ago, New Zealand's Treaty of Waitangi, the founding document of the nation, was signed!"

/datum/holiday/anz
	name = "ANZAC Day"
	timezones = list(TIMEZONE_TKT, TIMEZONE_TOT, TIMEZONE_NZST, TIMEZONE_NFT, TIMEZONE_LHST, TIMEZONE_AEST, TIMEZONE_ACST, TIMEZONE_ACWST, TIMEZONE_AWST, TIMEZONE_CXT, TIMEZONE_CCT, TIMEZONE_CKT, TIMEZONE_NUT)
	begin_day = 25
	begin_month = APRIL
	drone_hat = /obj/item/food/grown/poppy

/datum/holiday/anz/getStationPrefix()
	return pick("Australian","New Zealand","Poppy", "Southern Cross")

/datum/holiday/writer
	name = "Writer's Day"
	begin_day = 8
	begin_month = JULY

/datum/holiday/france
	name = "Bastille Day"
	timezones = list(TIMEZONE_CEST)
	begin_day = 14
	begin_month = JULY
	drone_hat = /obj/item/clothing/head/beret
	mail_holiday = TRUE

/datum/holiday/france/getStationPrefix()
	return pick("Francais","Fromage", "Zut", "Merde")

/datum/holiday/france/greet()
	return "Do you hear the people sing?"

/datum/holiday/friendship
	name = "Friendship Day"
	begin_day = 30
	begin_month = JULY

/datum/holiday/friendship/greet()
	return "Have a magical [name]!"

/datum/holiday/pirate
	name = "Talk-Like-a-Pirate Day"
	begin_day = 19
	begin_month = SEPTEMBER
	drone_hat = /obj/item/clothing/head/pirate

/datum/holiday/pirate/greet()
	return "Ye be talkin' like a pirate today or else ye'r walkin' tha plank, matey!"

/datum/holiday/pirate/getStationPrefix()
	return pick("Yarr","Scurvy","Yo-ho-ho")

/datum/holiday/programmers
	name = "Programmers' Day"

/datum/holiday/programmers/shouldCelebrate(dd, mm, yyyy, ddd) //Programmer's day falls on the 2^8th day of the year
	if(mm == 9)
		if(yyyy/4 == round(yyyy/4)) //Note: Won't work right on September 12th, 2200 (at least it's a Friday!)
			if(dd == 12)
				return TRUE
		else
			if(dd == 13)
				return TRUE
	return FALSE

/datum/holiday/programmers/getStationPrefix()
	return pick("span>","DEBUG: ","null","/list","EVENT PREFIX NOT FOUND") //Portability

/datum/holiday/questions
	name = "Stupid-Questions Day"
	begin_day = 28
	begin_month = SEPTEMBER

/datum/holiday/questions/greet()
	return "Are you having a happy [name]?"

/datum/holiday/animal
	name = "Animal's Day"
	begin_day = 4
	begin_month = OCTOBER

/datum/holiday/animal/getStationPrefix()
	return pick("Parrot","Corgi","Cat","Pug","Goat","Fox")

/datum/holiday/smile
	name = "Smiling Day"
	begin_day = 7
	begin_month = OCTOBER
	drone_hat = /obj/item/clothing/head/papersack/smiley

/datum/holiday/boss
	name = "Boss' Day"
	begin_day = 16
	begin_month = OCTOBER
	drone_hat = /obj/item/clothing/head/that

/datum/holiday/halloween
	name = HALLOWEEN
	begin_day = 29
	begin_month = OCTOBER
	end_day = 2
	end_month = NOVEMBER

/datum/holiday/halloween/greet()
	return "Have a spooky Halloween!"

/datum/holiday/halloween/getStationPrefix()
	return pick("Bone-Rattling","Mr. Bones' Own","2SPOOKY","Spooky","Scary","Skeletons")

/datum/holiday/vegan
	name = "Vegan Day"
	begin_day = 1
	begin_month = NOVEMBER

/datum/holiday/vegan/getStationPrefix()
	return pick("Tofu", "Tempeh", "Seitan", "Tofurkey")

/datum/holiday/october_revolution
	name = "October Revolution"
	begin_day = 6
	begin_month = NOVEMBER
	end_day = 7

/datum/holiday/october_revolution/getStationPrefix()
	return pick("Communist", "Soviet", "Bolshevik", "Socialist", "Red", "Workers'")

/datum/holiday/kindness
	name = "Kindness Day"
	begin_day = 13
	begin_month = NOVEMBER

/datum/holiday/flowers
	name = "Flowers Day"
	begin_day = 19
	begin_month = NOVEMBER
	drone_hat = /obj/item/food/grown/moonflower

/datum/holiday/hello
	name = "Saying-'Hello' Day"
	begin_day = 21
	begin_month = NOVEMBER

/datum/holiday/hello/greet()
	return "[pick(list("Aloha", "Bonjour", "Hello", "Hi", "Greetings", "Salutations", "Bienvenidos", "Hola", "Howdy", "Ni hao", "Guten Tag", "Konnichiwa", "G'day cunt"))]! " + ..()

/datum/holiday/human_rights
	name = "Human-Rights Day"
	begin_day = 10
	begin_month = DECEMBER

/datum/holiday/monkey
	name = MONKEYDAY
	begin_day = 14
	begin_month = DECEMBER
	drone_hat = /obj/item/clothing/mask/gas/monkeymask

/datum/holiday/islamic
	name = "Islamic calendar code broken"

/datum/holiday/islamic/shouldCelebrate(dd, mm, yyyy, ddd)
	var/datum/foreign_calendar/islamic/cal = new(yyyy, mm, dd)
	return ..(cal.dd, cal.mm, cal.yyyy, ddd)

/datum/holiday/islamic/ramadan
	name = "Start of Ramadan"
	begin_month = 9
	begin_day = 1
	end_day = 3

/datum/holiday/islamic/ramadan/getStationPrefix()
	return pick("Haram","Halaal","Jihad","Muslim", "Al", "Mohammad", "Rashidun", "Umayyad", "Abbasid", "Abdul", "Fatimid", "Ayyubid", "Almohad", "Abu")

/datum/holiday/islamic/ramadan/end
	name = "End of Ramadan"
	end_month = 10
	begin_day = 28
	end_day = 1

/datum/holiday/lifeday
	name = "Life Day"
	begin_day = 17
	begin_month = NOVEMBER

/datum/holiday/lifeday/getStationPrefix()
	return pick("Itchy", "Lumpy", "Malla", "Kazook") //he really pronounced it "Kazook", I wish I was making shit up

/datum/holiday/doomsday
	name = "Mayan Doomsday Anniversary"
	begin_day = 21
	begin_month = DECEMBER
	drone_hat = /obj/item/clothing/mask/animal/rat/tribal

/datum/holiday/xmas
	name = CHRISTMAS
	begin_day = 23
	begin_month = DECEMBER
	end_day = 27
	drone_hat = /obj/item/clothing/head/santa
	mail_holiday = TRUE

/datum/holiday/xmas/greet()
	return "Have a merry Christmas!"

/datum/holiday/xmas/celebrate()
	. = ..()
	SSticker.OnRoundstart(CALLBACK(src, .proc/roundstart_celebrate))
	GLOB.maintenance_loot += list(
		list(
			/obj/item/toy/xmas_cracker = 3,
			/obj/item/clothing/head/santa = 1,
			/obj/item/a_gift/anything = 1
		) = maint_holiday_weight,
	)

/datum/holiday/xmas/proc/roundstart_celebrate()
	for(var/obj/machinery/computer/security/telescreen/entertainment/Monitor in GLOB.machines)
		Monitor.icon_state_on = "entertainment_xmas"

	for(var/mob/living/simple_animal/pet/dog/corgi/ian/Ian in GLOB.mob_living_list)
		Ian.place_on_head(new /obj/item/clothing/head/helmet/space/santahat(Ian))


/datum/holiday/festive_season
	name = FESTIVE_SEASON
	begin_day = 1
	begin_month = DECEMBER
	end_day = 31
	drone_hat = /obj/item/clothing/head/santa

/datum/holiday/festive_season/greet()
	return "Have a nice festive season!"

/datum/holiday/boxing
	name = "Boxing Day"
	begin_day = 26
	begin_month = DECEMBER

/datum/holiday/friday_thirteenth
	name = "Friday the 13th"

/datum/holiday/friday_thirteenth/shouldCelebrate(dd, mm, yyyy, ddd)
	if(dd == 13 && ddd == FRIDAY)
		return TRUE
	return FALSE

/datum/holiday/friday_thirteenth/getStationPrefix()
	return pick("Mike","Friday","Evil","Myers","Murder","Deathly","Stabby")

/datum/holiday/easter
	name = EASTER
	drone_hat = /obj/item/clothing/head/rabbitears
	var/const/days_early = 1 //to make editing the holiday easier
	var/const/days_extra = 1

/datum/holiday/easter/shouldCelebrate(dd, mm, yyyy, ddd)
	if(!begin_month)
		current_year = text2num(time2text(world.timeofday, "YYYY"))
		var/list/easterResults = EasterDate(current_year+year_offset)

		begin_day = easterResults["day"]
		begin_month = easterResults["month"]

		end_day = begin_day + days_extra
		end_month = begin_month
		if(end_day >= 32 && end_month == MARCH) //begins in march, ends in april
			end_day -= 31
			end_month++
		if(end_day >= 31 && end_month == APRIL) //begins in april, ends in june
			end_day -= 30
			end_month++

		begin_day -= days_early
		if(begin_day <= 0)
			if(begin_month == APRIL)
				begin_day += 31
				begin_month-- //begins in march, ends in april

	return ..()

/datum/holiday/easter/celebrate()
	. = ..()
	GLOB.maintenance_loot += list(
		list(
			/obj/item/food/egg/loaded = 15,
			/obj/item/storage/basket/easter = 15
		) = maint_holiday_weight,
	)

/datum/holiday/easter/greet()
	return "Greetings! Have a Happy Easter and keep an eye out for Easter Bunnies!"

/datum/holiday/easter/getStationPrefix()
	return pick("Fluffy","Bunny","Easter","Egg")

/datum/holiday/ianbirthday
	name = "Ian's Birthday" //github.com/tgstation/tgstation/commit/de7e4f0de0d568cd6e1f0d7bcc3fd34700598acb
	begin_month = SEPTEMBER
	begin_day = 9
	end_day = 10

/datum/holiday/ianbirthday/greet()
	return "Happy birthday, Ian!"

/datum/holiday/ianbirthday/getStationPrefix()
	return pick("Ian", "Corgi", "Erro")

/datum/holiday/hotdogday //I have plans for this.
	name = "National Hot Dog Day"
	begin_day = 17
	begin_month = JULY

/datum/holiday/hotdogday/greet()
	return "Happy National Hot Dog Day!"

/datum/holiday/indigenous //Indigenous Peoples' Day from Earth!
	name = "International Day of the World's Indigenous Peoples"
	begin_month = AUGUST
	begin_day = 9

/datum/holiday/indigenous/getStationPrefix()
	return pick("Endangered language", "Word", "Language", "Language revitalization", "Potato", "Corn")

/datum/holiday/hebrew
	name = "If you see this the Hebrew holiday calendar code is broken"

/datum/holiday/hebrew/shouldCelebrate(dd, mm, yyyy, ddd)
	var/datum/foreign_calendar/hebrew/cal = new(yyyy, mm, dd)
	return ..(cal.dd, cal.mm, cal.yyyy, ddd)

/datum/holiday/hebrew/hanukkah
	name = "Hanukkah"
	begin_day = 25
	begin_month = 9
	end_day = 2
	end_month = 10

/datum/holiday/hebrew/hanukkah/greet()
	return "Happy [pick("Hanukkah", "Chanukah")]!"

/datum/holiday/hebrew/hanukkah/getStationPrefix()
	return pick("Dreidel", "Menorah", "Latkes", "Gelt")

/datum/holiday/hebrew/passover
	name = "Passover"
	begin_day = 15
	begin_month = 1
	end_day = 22

/datum/holiday/hebrew/passover/getStationPrefix()
	return pick("Matzah", "Moses", "Red Sea")

/datum/holiday/pride_week
	name = PRIDE_WEEK
	begin_month = JUNE
	// Stonewall was June 28th, this captures its week.
	begin_day = 23
	end_day = 29

	var/static/list/rainbow_colors = list(
		COLOR_PRIDE_PURPLE,
		COLOR_PRIDE_BLUE,
		COLOR_PRIDE_GREEN,
		COLOR_PRIDE_YELLOW,
		COLOR_PRIDE_ORANGE,
		COLOR_PRIDE_RED,
	)

/// Given an atom, will return what color it should be to match the pride flag.
/datum/holiday/pride_week/proc/get_floor_tile_color(atom/atom)
	var/turf/turf = get_turf(atom)
	return rainbow_colors[(turf.y % rainbow_colors.len) + 1]

/datum/holiday/remembrance_day
	name = "Remembrance Day"
	begin_month = NOVEMBER
	begin_day = 11
	drone_hat = /obj/item/food/grown/poppy

/datum/holiday/remembrance_day/getStationPrefix()
	return pick("Peace", "Armistice", "Poppy")

/datum/holiday/un_day
	name = "Anniversary of the Foundation of the United Nations"
	begin_month = OCTOBER
	begin_day = 24

/datum/holiday/un_day/greet()
	return "On this day in 1945, the United Nations was founded, laying the foundation for humanity's united government!"

/datum/holiday/un_day/getStationPrefix()
	return pick("United", "Cooperation", "Humanitarian")

//Gary Gygax's birthday, a fitting day for Wizard's Day
/datum/holiday/wizards_day
	name = "Wizard's Day"
	begin_month = JULY
	begin_day = 27
	drone_hat = /obj/item/clothing/head/wizard

/datum/holiday/wizards_day/getStationPrefix()
	return pick("Dungeon", "Elf", "Magic", "D20", "Edition")

//Species cultural holidays, based on days of significant PRs relating to their species
//Tiziran Unification Day is celebrated on Sept 1st, the day on which lizards were made a roundstart race
/datum/holiday/tiziran_unification
	name = "Tiziran Unification Day"
	begin_month = SEPTEMBER
	begin_day = 1

/datum/holiday/tiziran_unification/greet()
	return "On this day over 400 years ago, Lizardkind first united under a single banner, ready to face the stars as one unified people."

/datum/holiday/tiziran_unification/getStationPrefix()
	return pick("Tizira", "Lizard", "Imperial")

//The Festival of Atrakor's Might (Tizira's Moon) is celebrated on June 15th, the date on which the lizard visual revamp was merged (#9808)
/datum/holiday/atrakor_festival
	name = "Festival of Atrakor's Might"
	begin_month = JUNE
	begin_day = 15

/datum/holiday/atrakor_festival/greet()
	return "On this day, the Lizards traditionally celebrate the Festival of Atrakor's Might, where they honour the moon god with lavishly adorned clothing, large portions of food, and a massive celebration into the night."

/datum/holiday/atrakor_festival/getStationPrefix()
	return pick("Moon", "Night Sky", "Celebration")

//Draconic Day is celebrated on May 3rd, the date on which the Draconic language was merged (#26780)
/datum/holiday/draconic_day
	name = "Draconic Language Day"
	begin_month = MAY
	begin_day = 3

/datum/holiday/draconic_day/greet()
	return "On this day, Lizardkind celebrates their language with literature and other cultural works."

/datum/holiday/draconic_day/getStationPrefix()
	return pick("Draconic", "Literature", "Reading")

//Fleet Day is celebrated on Jan 19th, the date on which moths were merged (#34498)
/datum/holiday/fleet_day
	name = "Fleet Day"
	begin_month = JANUARY
	begin_day = 19

/datum/holiday/fleet_day/greet()
	return "This day commemorates another year of successful survival aboard the Mothic Grand Nomad Fleet. Moths galaxywide are encouraged to eat, drink, and be merry."

/datum/holiday/fleet_day/getStationPrefix()
	return pick("Moth", "Fleet", "Nomadic")

//The Festival of Holy Lights is celebrated on Nov 28th, the date on which ethereals were merged (#40995)
/datum/holiday/holy_lights
	name = "Festival of Holy Lights"
	begin_month = NOVEMBER
	begin_day = 28

/datum/holiday/holy_lights/greet()
	return "The Festival of Holy Lights is the final day of the Ethereal calendar. It is typically a day of prayer followed by celebration to close out the year in style."

/datum/holiday/holy_lights/getStationPrefix()
	return pick("Ethereal", "Lantern", "Holy")
