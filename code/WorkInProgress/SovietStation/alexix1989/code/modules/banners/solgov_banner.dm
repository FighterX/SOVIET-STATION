/obj/structure/banner/solgov
	name = "Sol Government Banner"
	desc = "A blue flag emblazoned with a golden logo of Sol Government hanging from a wooden stand."
	anchored = 1
	density = 1
	layer = 9
	icon = 'code/WorkInProgress/SovietStation/alexix1989/icons/banner.dmi'
	icon_state = "bannersol_down"

/obj/structure/banner/solgov/verb/toggle()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Banner"

	if(!usr.canmove || usr.stat || usr.restrained())
		return 0

	switch(icon_state)
		if("banner_down")
			src.icon_state = "bannersol_up"
			usr << "You roll up the cloth."
		if("banner_up")
			src.icon_state = "bannersol_down"
			usr << "You let the cloth hang loose."
		else
			usr << "You feel slightly dumber."
			return

	src.update_icon()

/obj/structure/banner/solgov/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		switch(anchored)
			if(0)
				anchored = 1
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] secures [src.name] to the floor.", "You secure [src.name] to the floor.", "You hear a ratchet")
			if(1)
				anchored = 0
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", "You unsecure [src.name] from the floor.", "You hear a ratchet")
		return
