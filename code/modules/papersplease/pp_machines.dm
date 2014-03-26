/*
	All the machinery from "Papers, please!" module for United Kingdom Of Soviet Station 13!

	Contains:
	--Mounted recorder. You can emag it to remove access restrictions. Can be destroyed.
	--ID machines, insert some work documents and get an ID card:
	---Automatic. It can be destroyed by blob and explosions. Can only print one card per person.
	---Customs. Can't be destroyed, since it would be a pin in da ass. Can print unlimited amount of cards.
	--"DETAIN" button. Press it to call security. Can be destroyed. Emag it and press to get some funny results.
*/

/obj/machinery/mounted_recorder
	desc = "A device that can record dialogues and print them later. It automatically translates the content in print-out."
	name = "mounted recorder"
	icon = 'icons/obj/radio.dmi'
	icon_state = "intercom"
	req_access_txt = "1"
	anchored = 1
	var/list/storedinfo = new/list()

/obj/machinery/mounted_recorder/hear_talk(mob/living/M as mob, msg)
	var/ending = copytext(msg, length(msg))
	if(M.stuttering)
		storedinfo += "[M.name] stammers, \"[msg]\""
		return
	if(M.getBrainLoss() >= 60)
		storedinfo += "[M.name] gibbers, \"[msg]\""
		return
	if(ending == "?")
		storedinfo += "[M.name] asks, \"[msg]\""
		return
	else if(ending == "!")
		storedinfo += "[M.name] exclaims, \"[msg]\""
		return
	storedinfo += "[M.name] says, \"[msg]\""
	return

/obj/machinery/mounted_recorder/verb/clear_memory()
	set src in view(1)
	set name = "Clear Memory"
	set category = "Object"

	if(usr.stat)
		return
	if(!allowed(usr))
		usr << "\red Access Denied"
		return
	if(storedinfo)	storedinfo.Cut()
	usr << "<span class='notice'>Memory cleared.</span>"
	return

/obj/machinery/mounted_recorder/verb/print_transcript()
	set src in view(1)
	set name = "Print Transcript"
	set category = "Object"

	if(usr.stat)
		return
	if(!allowed(usr))
		usr << "\red Access Denied"
		return
	usr << "<span class='notice'>Transcript printed.</span>"
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i=1,storedinfo.len >= i,i++)
		t1 += "[storedinfo[i]]<BR>"
	P.info = t1
	P.name = "paper- 'Customs print-out'"

/obj/machinery/mounted_recorder/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/emag))
		req_access_txt = "0"
		playsound(src.loc, "sparks", 100, 1)
	return src.attack_hand(user)

/obj/machinery/mounted_recorder/ex_act(severity)
	switch(severity)
		if(1)
			if(prob(50))
				del(src)
		if(2)
			if(prob(25))
				del(src)

/obj/machinery/mounted_recorder/blob_act()
	if(prob(50))
		del(src)


/obj/structure/id_machine
	name = "ID machine"
	desc = "Job docs in, IDs out!"
	icon = 'icons/obj/pp.dmi'
	icon_state = "id_machine_on"

	var/enabled = 1
	//var/area/customs/assigned_area = null

/obj/structure/id_machine/attackby(obj/item/weapon/papersplease/workdoc/W, mob/user as mob)
	if(enabled)
		//if((!user.dna.unique_enzymes in assigned_area.given_enzymes) && (user.dna.uni_identity in assigned_area.given_unique))
		if(!(user.dna.unique_enzymes in Customs.given_enzymes) && !(user.dna.uni_identity in Customs.given_unique))
			if(istype(W))
				//user << W.assigned_name
				//user << W.job
				Customs.given_enzymes += user.dna.unique_enzymes
				Customs.given_unique += user.dna.uni_identity
				var/obj/item/weapon/card/id/new_id = null
				for(var/J in (typesof(/datum/job) - /datum/job))
					var/datum/job/n_job = new J()
					//world << n_job.title
					if( (W.job == n_job.title) || (W.job in n_job.alt_titles))
						//world << "FOUND ONE!"
						new_id = new n_job.idtype(loc)
						new_id.registered_name = W.assigned_name
						new_id.assignment = W.job
						new_id.name = "[new_id.registered_name]'s ID Card ([new_id.assignment])"
						new_id.blood_type = user:dna:b_type
						new_id.dna_hash = user:dna:unique_enzymes
						new_id.fingerprint_hash = md5(user:dna:uni_identity)

						new_id.access = n_job.get_access()
						return
		else
			user << "\red Your card is already printed"

/obj/structure/id_machine/ex_act(severity)
	switch(severity)
		if(1)
			if(prob(50))
				del(src)
		if(2)
			if(prob(25))
				del(src)

/obj/structure/id_machine/blob_act()
	if(prob(50))
		del(src)

/obj/structure/id_machine_customs
	name = "ID machine"
	desc = "Job docs in, IDs out!"
	icon = 'icons/obj/pp.dmi'
	icon_state = "id_machine_customs_off"

	var/enabled = 0

/obj/structure/id_machine_customs/attackby(obj/item/weapon/papersplease/workdoc/W, mob/living/carbon/human/user as mob)
	if(enabled)
		if(istype(W))
			var/obj/item/weapon/card/id/new_id = null
			for(var/J in (typesof(/datum/job) - /datum/job))
				var/datum/job/n_job = new J()
				if((W.job == n_job.title) || (W.job in n_job.alt_titles))
					new_id = new n_job.idtype(loc)
					new_id.registered_name = W.assigned_name
					new_id.assignment = W.job
					new_id.name = "[new_id.registered_name]'s ID Card ([new_id.assignment])"
					new_id.blood_type = user:dna:b_type
					new_id.dna_hash = user:dna:unique_enzymes
					new_id.fingerprint_hash = md5(user:dna:uni_identity)

					new_id.access = n_job.get_access()
					return

/obj/machinery/detain
	name = "DETAIN"
	desc = "Use it to call serious guys"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	power_channel = EQUIP
	anchored = 1.0
	use_power = 1
	idle_power_usage = 4
	req_access_txt = "1"

	var/obj/item/device/radio/radio

/obj/machinery/detain/New()
	..()
	radio = new /obj/item/device/radio(src)
	radio.config(list("Security"))

/obj/machinery/detain/Del()
	del radio

/obj/machinery/detain/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/emag))
		req_access_txt = "0"
		playsound(src.loc, "sparks", 100, 1)
	return src.attack_hand(user)

/obj/machinery/detain/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user))
		user << "\red Access Denied"
		flick("doorctrl-denied",src)
		return

	use_power(5)
	icon_state = "doorctrl1"
	if(req_access_txt == "0")
		radio.talk_into(user, "Yo, shitcurity guys! Come get me!", "Security")		//I don't really know. Just don't feel like writing a new system for ONE DAMN BUTTON!
	else
		radio.talk_into(user, "Need help at Customs!", "Security")		//I don't really know. Just don't feel like writing a new system for ONE DAMN BUTTON!

	spawn(15)
		if(!(stat & NOPOWER))
			icon_state = "doorctrl0"

/obj/machinery/detain/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/obj/machinery/detain/ex_act(severity)
	switch(severity)
		if(1)
			if(prob(50))
				del(src)
		if(2)
			if(prob(25))
				del(src)

/obj/machinery/detain/blob_act()
	if(prob(50))
		del(src)
