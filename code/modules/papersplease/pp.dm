//Base class, do not use in-game
/obj/item/weapon/papersplease
	name = "PAPERS"
	desc = "PLEASE"
	icon = 'icons/obj/pp.dmi'
	w_class = 1.0

	var/code = ""
	var/assigned_name = ""
	var/expires = 0

	var/list/stamps = list()		//For those maniacs who like stamping passports
	var/list/open_overlay = list()	//So we can store all the stamps when the passport is closed

/obj/item/weapon/papersplease/New()
	..()
	expires = game_year + rand(5,15)

/obj/item/weapon/papersplease/passport
	name = "passport"
	desc = "Standart NT issued passport."
	icon_state = "low_pass_closed"
	var/assigned_gender = ""
	var/assigned_age = 0
	var/arrival = ""
	var/closed = 1

/obj/item/weapon/papersplease/passport/head
	name = "head passport"
	desc = "Standart NT issued passport for the heads of staff."
	icon_state = "medium_pass_closed"

/obj/item/weapon/papersplease/passport/captain
	name = "captain's passport"
	desc = "Captain's passport. Is it golden?!"
	icon_state = "high_pass_closed"

/obj/item/weapon/papersplease/passport/New()
	..()
	for(var/i = 0, i < 10, i++)
		var/let = rand(0,35)				//0-9 - numbers(0-9) 10-35 - letters(a-z)
		if(let <= 9)
			code += num2text(let)
		else
			code += ascii2text(let+55)
		if(i == 4)
			code += "-"

/obj/item/weapon/papersplease/passport/attack_self(mob/user as mob)
	if(!closed)
		user.set_machine(src)

		var/dat = "<title>Passport</title><body bgcolor=\"#CECE40\">"
		dat += "Name : " + assigned_name + "<BR>"
		dat += "Gender : " + assigned_gender + "<BR>"
		dat += "Born : " + num2text(game_year - assigned_age) + "<BR>"
		dat += "Home City : " + arrival + "<BR>"
		dat += "Expires : " + num2text(expires) + "<BR><HR>"
		dat += code + "<BR><BR>"
		if(stamps.len > 0)
			for(var/c = 1 to stamps.len)
				dat += "<i>" + stamps[c] + "</i><BR>"

		user << browse(dat, "window=passport")
		onclose(user, "passport")
		add_fingerprint(usr)
		return
	else
		show()

/obj/item/weapon/papersplease/passport/attackby(obj/item/weapon/customs_stamp/W, mob/user as mob)
	if(istype(W, /obj/item/weapon/customs_stamp/approved) || istype(W, /obj/item/weapon/customs_stamp/denied))
		if(!closed)
			if(!in_range(src, usr))
				return

			var/image/stampoverlay = image('icons/obj/pp.dmi')
			stampoverlay.pixel_x = rand(-1, 1)
			stampoverlay.pixel_y = rand(-1, 1)
			if(istype(W, /obj/item/weapon/customs_stamp/approved))
				stampoverlay.icon_state = "access_stamp"
			else
				stampoverlay.icon_state = "denied_stamp"

			stamps += "It was stamped with [W.name]"
			overlays += stampoverlay

			user << "<span class='notice'>You stamp the paper with your stamp.</span>"
		else
			show()

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
		arrival = "Tau-Ceti C	ity"

/obj/item/weapon/papersplease/passport/verb/show()
	set src in usr
	set category = "Object"
	set name = "Open/Close passport"

	closed = !closed
	if(closed)
		icon_state = icon_state + "_closed"
		open_overlay = overlays.Copy()
		overlays.Cut()
		w_class = 1
	else
		icon_state = copytext(icon_state,1,length(icon_state) - 6)
		overlays = open_overlay.Copy()
		w_class = 2			//You don't usually store opened passports in your pockets, do you?

/obj/item/weapon/papersplease/entrance_doc
	name = "entrance document"
	desc = "Standart NT issued entrance ticket."
	icon_state = "access_personnel"

/obj/item/weapon/papersplease/entrance_doc/attack_self(mob/user as mob)
	user.set_machine(src)

	var/dat = "<title>Entrance Document</title><body bgcolor=\"#CECE40\">"
	dat += "Name : " + assigned_name + "<BR>"
	dat += "Code : " + code + "<BR>"
	dat += "Expires : " + num2text(expires) + "<BR>"
	dat += "Reason : Work<BR>"

	user << browse(dat, "window=entrancedoc")
	onclose(user, "entrancedoc")
	add_fingerprint(usr)
	return

/obj/item/weapon/papersplease/entrance_doc/proc/set_data(obj/item/weapon/papersplease/passport/usepass)
	code = usepass.code
	assigned_name = usepass.name

/obj/item/weapon/papersplease/workdoc
	name = "job documents"
	desc = "Standart NT issued document, proving it's owner is just a normal employee."
	icon_state = "work_doc"

	var/job = ""

/obj/item/weapon/papersplease/workdoc/attack_self(mob/user as mob)
	user.set_machine(src)

	var/dat = "<title>Work Document</title><body bgcolor=\"#CECE40\">"
	dat += "Name : " + assigned_name + "<BR>"
	dat += "Job : " + job + "<BR>"
	dat += "Expires : " + num2text(expires) + "<BR>"

	user << browse(dat, "window=workdoc")
	onclose(user, "workdoc")
	add_fingerprint(usr)
	return

//Well, new employees don't have IDs, so I have to use this
/obj/item/weapon/papersplease/workdoc/proc/set_data(title, name, new_code)
	job = title
	assigned_name = name
	code = new_code


/obj/item/weapon/papersplease/workdoc/headdoc
	name = "head document"
	desc = "Standart NT issued document, proving it's owner is pretty damn important."
	icon_state = "access_head"

/obj/item/weapon/papersplease/workdoc/headdoc/attack_self(mob/user as mob)
	user.set_machine(src)

	var/dat = "<title>Head Document</title><body bgcolor=\"#CECE40\">"
	dat += "Name : " + assigned_name + "<BR>"
	dat += "Rank : " + job + "<BR>"
	dat += "Expires : " + num2text(expires) + "<BR>"

	user << browse(dat, "window=headdoc")
	onclose(user, "headdoc")		//Just in case someone wants to open two workdocs at once
	add_fingerprint(usr)
	return


/area/customs
	name = "Arrival Customs"
	icon = 'icons/obj/pp.dmi'
	icon_state = "customs"


/obj/item/weapon/customs_stamp
	desc = "A rubber stamp which is used to stamp passports"
	icon = 'icons/obj/bureaucracy.dmi'
	w_class = 1

/obj/item/weapon/customs_stamp/approved
	name = "\improper APPROVED stamp"
	icon_state = "stamp-cent"

/obj/item/weapon/customs_stamp/denied
	name = "\improper DENIED stamp"
	icon_state = "stamp-hos"
