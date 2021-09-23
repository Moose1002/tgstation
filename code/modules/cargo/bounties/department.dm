/datum/bounty/item/departmental
	var/list/wanted_items

/datum/bounty_item
	var/required_item
	var/required_count = 1

/datum/bounty_item/New(required_item, required_count)
	src.required_item = required_item
	src.required_count = required_count

/datum/bounty/item/departmental/service/feast
	name = "Shareholder Feast"
	description = "An annual shareholder meeting is coming up and Nanotrasen is looking to host a grand event! We're gonna need a huge feast to feed all participants. Ship enough food to feed our investors."
	reward = CARGO_CRATE_VALUE * 25
	required_count = 3
	wanted_items = list(/datum/bounty_item = new(/obj/item/food/soup, 4))
	wanted_types = list(/obj/item/food/soup)
	departmental = TRUE
