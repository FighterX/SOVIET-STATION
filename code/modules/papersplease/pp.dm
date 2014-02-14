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
	expires = game_year + rand(5,15)
	for(var/i = 0, i < 10, i++)
		var/let = rand(1,37)				//1-10 - numbers(0-9) 11-36 - letters(a-z)
		if(let <= 10)
			code += num2text(let - 1)
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
/obj/item/weapon/papersplease/workdoc/proc/set_data(var/title, var/name, var/new_code)
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
/obj/item/weapon/papersplease/headdoc/proc/set_data(var/title, var/name, var/new_code)
	job = title
	assigned_name = name
	code = new_code
