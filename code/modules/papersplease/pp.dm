//Base class, do not use in-game
/obj/item/weapon/papersplease
	name = "PAPERS"
	desc = "PLEASE"
	icon = 'icons/obj/pp.dmi'
	w_class = 1.0

	var/code = ""
	var/assigned_name = ""
	var/expires = 0

	var/stamp = ""

/obj/item/weapon/papersplease/New()
	..()
	expires = game_year + rand(5,15)

/obj/item/weapon/papersplease/passport
	name = "passport"
	desc = "Standart NT issued passport."
	icon_state = "passport"
	var/assigned_gender = ""
	var/assigned_age = 0
	var/arrival = ""

/obj/item/weapon/papersplease/passport/New()
	..()
	for(var/i = 0, i < 10, i++)
		var/let = rand(0,36)				//0-9 - numbers(0-9) 10-35 - letters(a-z)
		if(let <= 9)
			code += num2text(let)
		else
			code += ascii2text(let+54)
		if(i == 4)
			code += "-"

/obj/item/weapon/papersplease/passport/attack_self(mob/user as mob)
	user.set_machine(src)

	var/dat = "<title>Passport</title><body bgcolor=\"#CECE40\">"
	dat += "Name : " + assigned_name + "\n"
	dat += "Gender : " + assigned_gender + "\n"
	dat += "Born : " + num2text(game_year - assigned_age) + "\n"
	dat += "Home City : " + arrival + "\n"
	dat += "Expires : " + num2text(expires) + "\n<HR>"
	dat += code

	user << browse(dat, "window=passport")
	onclose(user, "passport")
	add_fingerprint(usr)
	return

/obj/item/weapon/papersplease/passport/proc/set_data(mob/living/carbon/human/use)
	assigned_name = use.name
	assigned_gender = (use.gender==MALE?"male":"female")
	assigned_age = use.age

	var/city = rand(1,3)
	if(city == 1)
		arrival = "Earth City"
	else if(city == 2)
		arrival = "Mars City"
	else
		arrival = "Tau-Ceti City"


/obj/item/weapon/papersplease/entrance_doc
	name = "entrance document"
	desc = "Standart NT issued entrance ticket."
	icon_state = "entrance"

/obj/item/weapon/papersplease/entrance_doc/attack_self(mob/user as mob)
	user.set_machine(src)

	var/dat = "<title>Entrance Document</title><body bgcolor=\"#CECE40\">"
	dat += "Name : " + assigned_name + "\n"
	dat += "Code : " + code + "\n"
	dat += "Expires : " + num2text(expires) + "\n"
	dat += "Reason : Work\n"

	user << browse(dat, "window=entrancedoc")
	onclose(user, "entrancedoc")
	add_fingerprint(usr)
	return

/obj/item/weapon/papersplease/entrance_doc/proc/set_data(obj/item/weapon/papersplease/passport/usepass)
	code = usepass.code
	assigned_name = usepass.name

/obj/item/weapon/papersplease/workdoc
	name = "Work documents"
	desc = "Standart NT issued document, proving it's owner is a normal employee."
	icon_state = "workdoc"

	var/job = ""

/obj/item/weapon/papersplease/workdoc/attack_self(mob/user as mob)
	user.set_machine(src)

	var/dat = "<title>Work Document</title><body bgcolor=\"#CECE40\">"
	dat += "Name : " + assigned_name + "\n"
	dat += "Job : " + job + "\n"
	dat += "Expires : " + num2text(expires) + "\n"

	user << browse(dat, "window=workdoc")
	onclose(user, "workdoc")
	add_fingerprint(usr)
	return

//Well, new employees don't have IDs, so I have to use this
/obj/item/weapon/papersplease/workdoc/proc/set_data(title, name, new_code)
	job = title
	assigned_name = name
	code = new_code


/obj/item/weapon/papersplease/headdoc
	name = "Head document"
	desc = "Standart NT issued document, proving it's owner is pretty damn important."
	icon_state = "headdoc"

	var/job = ""

/obj/item/weapon/papersplease/headdoc/attack_self(mob/user as mob)
	user.set_machine(src)

	var/dat = "<title>Head Document</title><body bgcolor=\"#CECE40\">"
	dat += "Name : " + assigned_name + "\n"
	dat += "Rank : " + job + "\n"
	dat += "Expires : " + num2text(expires) + "\n"

	user << browse(dat, "window=workdoc")
	onclose(user, "workdoc")
	add_fingerprint(usr)
	return

//Well, new employees don't have IDs, so I have to use this
/obj/item/weapon/papersplease/headdoc/proc/set_data(title, name, new_code)
	job = title
	assigned_name = name
	code = new_code


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


/obj/item/weapon/stamp/approved
	name = "\improper APPROVED stamp"
	desc = "A rubber stamp for stamping passports and entrance documents."
	icon = 'icons/obj/pp.dmi'
	icon_state = "approved"

//DENIED stamp is in code/modules/paperwork/stamps.dm


var/const/check_customs_rate = 3000		//~5 minutes

/area/customs
	name = "Arrival Customs"
	icon = 'icons/obj/pp.dmi'
	icon_state = "customs"

	//var/obj/checker = null

	//var/list/id_machines = list()
	//var/list/id_machines_customs = list()

	//var/list/given_enzymes = list()
	//var/list/given_unique = list()

/*
/area/customs/proc/check_customs(respawn=1 as num)
	var/checked = 0
	for(var/mob/living/carbon/possible_guard in contents)
		if(checker.allowed(possible_guard))
			for(var/obj/structure/id_machine/change in id_machines)
				change.enabled = 0
			for(var/obj/structure/id_machine_customs/change in id_machines_customs)
				change.enabled = 1
			checked = 1
			break			//It's kinda bad, but oh well

	if(!checked)
		for(var/obj/structure/id_machine/change in id_machines)
			change.enabled = 1
		for(var/obj/structure/id_machine_customs/change in id_machines_customs)
			change.enabled = 0

	if(respawn)
		spawn(check_customs_rate)
			check_customs()

	return
*/

/*
/area/customs/New()
	..()
	world.log << "CUSTOMS AREA CREATED!"
	//checker = new /obj(src)
	//checker.req_access_txt = "1"
	//spawn(5)
	//	check_customs()
	//spawn(15)
	if(src == null)
		world.log << "NULL"
	var/list/search = world.contents.Copy()
	for(var/obj/structure/id_machine/to_add in search)
		if(!to_add in id_machines)
			id_machines += to_add
			to_add.assigned_area = src
	for(var/obj/structure/id_machine_customs/to_add in search)
		if(!to_add in id_machines_customs)
			id_machines_customs += to_add
			to_add.assigned_area = src
*/


/*
/area/customs/Del()
	..()
	del checker
*/
