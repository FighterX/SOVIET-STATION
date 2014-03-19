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


/obj/structure/id_machine
	name = "ID machine"
	desc = "Job docs in, IDs out!"
	icon = 'icons/obj/pp.dmi'
	icon_state = "id_machine"

	var/enabled = 1
	//var/area/customs/assigned_area = null

/obj/structure/id_machine/attackby(obj/item/weapon/papersplease/W, mob/user as mob)
	if(enabled)
		//if((!user.dna.unique_enzymes in assigned_area.given_enzymes) && (user.dna.uni_identity in assigned_area.given_unique))
		if(!(user.dna.unique_enzymes in Customs.given_enzymes) && (user.dna.uni_identity in Customs.given_unique))
			if(istype(W, /obj/item/weapon/papersplease/workdoc) || istype(W, /obj/item/weapon/papersplease/headdoc))
				user << W.assigned_name
				user << W:job
				//assigned_area.given_enzymes += user.dna.unique_enzymes
				//assigned_area.given_unique += user.dna.uni_identity
				Customs.given_enzymes += user.dna.unique_enzymes
				Customs.given_unique += user.dna.uni_identity
		else
			user << "/red Your card is already printed"

/obj/structure/id_machine_customs
	name = "ID machine"
	desc = "Job docs in, IDs out!"
	icon = 'icons/obj/pp.dmi'
	icon_state = "id_machine_customs"

	var/enabled = 0
	var/area/customs/assigned_area

/obj/structure/id_machine_customs/attackby(obj/item/weapon/papersplease/W, mob/living/carbon/human/user as mob)
  if(enabled && istype(user))
		if(istype(W, /obj/item/weapon/papersplease/workdoc) || istype(W, /obj/item/weapon/papersplease/headdoc))
			user << W.assigned_name
			user << W:job
			var/obj/item/weapon/card/id/new_id = new(src.loc)
			new_id.registered_name = W.assigned_name
			new_id.blood_type = user:dna:b_type
			new_id.dna_hash = user:dna:unique_enzymes
			new_id.fingerprint_hash = md5(user:dna:uni_identity)
