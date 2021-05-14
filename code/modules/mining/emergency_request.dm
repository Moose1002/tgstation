/obj/machinery/computer/emergency_request
	name = "emergency request console"
	desc = "A console used to beam supplies down to miners when they end up in sticky situations."
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express
	req_access = list(ACCESS_QM)

	var/locked = TRUE

/obj/machinery/computer/emergency_request/attackby(obj/item/W, mob/living/user, params)
	if(W.GetID() && allowed(user))
		locked = !locked
		to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the interface.</span>")
		return
