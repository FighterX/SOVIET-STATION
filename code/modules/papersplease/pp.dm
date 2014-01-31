#define CUR_YEAR 2556

/obj/item/weapon/passport
	name = "passport"
	desc = "Standart NT issued passport"
	icon = 'icons/obj/pp.dmi'
	icon_state = "passport"
	w_class = 1.0
	var/code = ""
	var/assigned_name = ""
	var/assigned_gender = ""
	var/assigned_age = 0
	var/expires = 0
	var/arrival = ""
	
/obj/item/weapon/passport/New()
	..()
	for(var/i = 0, i < 10, i++)
		var/let = rand(1,37)				//1-10 - numbers(0-9) 11-36 - letters(a-z)
		if(let <= 10)
			code += num2text(let - 1)
		else
			code += ascii2text(let+54)
		if(i == 4)
			code += "-"
			
/obj/item/weapon/passport/proc/set_data(/mob/living/carbon/human/use as mob)
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

/obj/item/weapon/passport/attack_self(mob/user as mob)
	user.set_machine(src)
	
	var/dat = "<title>Passport</title><body bgcolor=\"#CECE40\">"
	dat += "Name : " + assigned_name + "\n"
	dat += "Gender : " + assigned_gender + "\n"
	dat += "Born : " + num2text(CUR_YEAR - assigned_age) + "\n"
	dat += "Home City : " + arrival + "\n"
	dat += "Expires : " + num2text(expires) + "\n<HR>"
	dat += code

	user << browse(dat, "window=passport")
	onclose(user, "clipboard")
	add_fingerprint(usr)
	return
