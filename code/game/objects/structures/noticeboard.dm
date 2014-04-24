/obj/structure/noticeboard
	name = "notice board"
	desc = "A board for pinning important notices upon."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	flags = FPRINT
	density = 0
	anchored = 1
	var/notices = 0

/obj/structure/noticeboard/initialize()
	for(var/obj/item/I in loc)
		if(notices > 4) break
		if(istype(I, /obj/item/weapon/paper))
			I.loc = src
			notices++
	icon_state = "nboard0[notices]"

//attaching papers!!
/obj/structure/noticeboard/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper))
		if(notices < 5)
			O.add_fingerprint(user)
			add_fingerprint(user)
			user.drop_item()
			O.loc = src
			notices++
			icon_state = "nboard0[notices]"	//update sprite
			user << "<span class='notice'>You pin the paper to the noticeboard.</span>"
		else
			user << "<span class='notice'>You reach to pin your paper to the board but hesitate. You are certain your paper will not be seen among the many others already attached.</span>"

/obj/structure/noticeboard/attack_hand(user as mob)
	var/dat = "<B>Noticeboard</B><BR>"
	for(var/obj/item/weapon/paper/P in src)
		dat += "<A href='?src=\ref[src];read=\ref[P]'>[P.name]</A> <A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A><BR>"
	user << browse("<HEAD><TITLE>Notices</TITLE></HEAD>[dat]","window=noticeboard")
	onclose(user, "noticeboard")


/obj/structure/noticeboard/Topic(href, href_list)
	..()
	usr.set_machine(src)
	if(href_list["remove"])
		if((usr.stat || usr.restrained()))	//For when a player is handcuffed while they have the notice window open
			return
		var/obj/item/P = locate(href_list["remove"])
		if((P && P.loc == src))
			P.loc = get_turf(src)	//dump paper on the floor because you're a clumsy fuck
			P.add_fingerprint(usr)
			add_fingerprint(usr)
			notices--
			icon_state = "nboard0[notices]"

	if(href_list["write"])
		if((usr.stat || usr.restrained())) //For when a player is handcuffed while they have the notice window open
			return
		var/obj/item/P = locate(href_list["write"])

		if((P && P.loc == src)) //ifthe paper's on the board
			if(istype(usr.r_hand, /obj/item/weapon/pen)) //and you're holding a pen
				add_fingerprint(usr)
				P.attackby(usr.r_hand, usr) //then do ittttt
			else
				if(istype(usr.l_hand, /obj/item/weapon/pen)) //check other hand for pen
					add_fingerprint(usr)
					P.attackby(usr.l_hand, usr)
				else
					usr << "<span class='notice'>You'll need something to write with!</span>"

	if(href_list["read"])
		var/obj/item/weapon/paper/P = locate(href_list["read"])
		if((P && P.loc == src))
			if(!( istype(usr, /mob/living/carbon/human) ))
				usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY><TT>[stars(P.info)]</TT></BODY></HTML>", "window=[P.name]")
				onclose(usr, "[P.name]")
			else
				usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY><TT>[P.info]</TT></BODY></HTML>", "window=[P.name]")
				onclose(usr, "[P.name]")
	return

/obj/structure/noticeboard/assistant_nb

/obj/structure/noticeboard/assistant_nb/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper))
		if(notices < 5)
			O.add_fingerprint(user)
			add_fingerprint(user)
			user.drop_item()
			O.loc = src
			notices++
			icon_state = "nboard0[notices]"
			for(var/obj/structure/noticeboard/assistant_nb/nBoard in world)
				if(nBoard != src)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(nBoard.loc)
					P.name = O:name
					P.info = O:info
					P.info_links = O:info_links
					P.stamps = O:stamps
					P.fields = O:fields
					P.update_icon()
					P.updateinfolinks()
					P.stamped = O:stamped
					P.overlays = O:overlays
					P.loc = nBoard
					nBoard.notices++
					nBoard.icon_state = "nboard0[nBoard.notices]"
			user << "<span class='notice'>You pin the paper to the noticeboard.</span>"
		else
			user << "<span class='notice'>You reach to pin your paper to the board but hesitate. You are certain your paper will not be seen among the many others already attached.</span>"
