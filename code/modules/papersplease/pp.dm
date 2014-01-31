#define CUR_YEAR 2556

//Base class, do not use in-game
/obj/item/weapon/papersplease
	name = "GLORY!"
	desc = "TO BARS!"
	icon = 'icons/obj/pp.dmi'
	w_class = 1.0
	
	var/code = ""
	var/assigned_name = ""

/obj/item/weapon/papersplease/passport
	name = "passport"
	desc = "Standart NT issued passport"
	icon_state = "passport"
	var/assigned_gender = ""
	var/assigned_age = 0
	var/expires = 0
	var/arrival = ""
	
/obj/item/weapon/papersplease/passport/New()
	..()
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
	dat += "Born : " + num2text(CUR_YEAR - assigned_age) + "\n"
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
	expires = CUR_YEAR + rand(5,15)
	
	var/city = rand(1,3)
	if(city == 1)
		arrival = "Earth City"
	else if(city == 2)
		arrival = "Mars City"
	else
		arrival = "Tau-Ceti City"


/obj/item/weapon/papersplease/entrance_doc
	name = "entrance document"
	desc = "Standart NT issued entrance ticket"
	icon_state = "entrance"
	
	var/expires = 0
	
/obj/item/weapon/papersplease/entrance_doc/New()
	..()
	expires = CUR_YEAR + rand(5,15)

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
