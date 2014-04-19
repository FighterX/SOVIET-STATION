/obj/item/weapon/spacecash
	name = "0 credit chip"
	desc = "It's worth 0 credits."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "spacecash"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	var/access = list()
	access = access_crate_cash
	var/worth = 0
	var/list/stack = list()

obj/item/weapon/spacecash/attackby(obj/item/I, mob/living/user)
	..()
	if(istype(I, /obj/item/weapon/spacecash/))
		var/obj/item/weapon/spacecash/cashstack/C = I
		var/obj/item/weapon/spacecash/cashstack/S = new /obj/item/weapon/spacecash/cashstack(usr.loc)
		S.stack += src.stack
		S.worth += src.worth
		S.stack += C.stack
		S.worth += C.worth
		S.update_cash_data()
		user.u_equip(C)
		S.pickup(user)
		user.put_in_any_hand_if_possible(S)
		del(C)
		del(src)

/obj/item/weapon/spacecash/cashstack
	name = "Cash stack"
	worth = 0
	desc = "It's worth 0 credits."
	icon_state = "spacecash"
	var/datum/browser/popup = null

/obj/item/weapon/spacecash/cashstack/proc/update_cash_data()
	desc = "It's worth [worth] credits."
	for(var/i in list(1000,500,200,100,50,20,10))
		if(worth>i)
			icon_state = "spacecash[i]"
			return
	icon_state = "spacecash"

obj/item/weapon/spacecash/cashstack/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

obj/item/weapon/spacecash/cashstack/interact(mob/user)
	var/k = 0
	var/dat = "Cash stack worth [worth] credits.<BR>"
	for(var/i in list(1000,500,200,100,50,20,10,1))
		k = 0
		for(var/q in src.stack)
			if(q == "[i] credit chip")
				k++
		if(k != 0)
			dat += "[i]cr x[k] <A href='?src=\ref[src];cash_worth=[i];cash_multi=1'>x1</A>"
			for(var/l in list(5,10,20,50,100))
				if(k > l)
					dat += "<A href='?src=\ref[src];cash_worth=[i];cash_multi=[l]'>x[l]</A>"
			dat += "<BR>"
	popup = new(user, "cashstack", "Stack of Cash", 300, 300)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()

obj/item/weapon/spacecash/cashstack/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/moneyUser = usr
	if(href_list["cash_worth"])
		if (moneyUser.get_active_hand() == src || moneyUser.get_inactive_hand() == src)
			if(href_list["cash_multi"])
				var/cash_worth = max(text2num(href_list["cash_worth"]),0)
				var/cash_multi = max(text2num(href_list["cash_multi"]),0)
				var/i = 0
				var/type = null
				while(i < cash_multi)
					src.stack -= "[cash_worth] credit chip"
					type = text2path("/obj/item/weapon/spacecash/c[cash_worth]")
					new type(moneyUser.loc)
					i++
				worth -= (cash_worth * cash_multi)
				if(src.stack.len == 1)
					type = text2path("/obj/item/weapon/spacecash/c[worth]")
					new type(moneyUser.loc)
					src.popup.close()
					del(src)
				else
					src.update_cash_data()
					interact(moneyUser)
		return

/obj/item/weapon/spacecash/c1
	name = "1 credit chip"
	icon_state = "spacecash"
	desc = "It's worth 1 credit."
	worth = 1
	stack = "1 credit chip"

/obj/item/weapon/spacecash/c10
	name = "10 credit chip"
	icon_state = "spacecash10"
	desc = "It's worth 10 credits."
	worth = 10
	stack = "10 credit chip"

/obj/item/weapon/spacecash/c20
	name = "20 credit chip"
	icon_state = "spacecash20"
	desc = "It's worth 20 credits."
	worth = 20
	stack = "20 credit chip"

/obj/item/weapon/spacecash/c50
	name = "50 credit chip"
	icon_state = "spacecash50"
	desc = "It's worth 50 credits."
	worth = 50
	stack = "50 credit chip"

/obj/item/weapon/spacecash/c100
	name = "100 credit chip"
	icon_state = "spacecash100"
	desc = "It's worth 100 credits."
	worth = 100
	stack = "100 credit chip"

/obj/item/weapon/spacecash/c200
	name = "200 credit chip"
	icon_state = "spacecash200"
	desc = "It's worth 200 credits."
	worth = 200
	stack = "200 credit chip"

/obj/item/weapon/spacecash/c500
	name = "500 credit chip"
	icon_state = "spacecash500"
	desc = "It's worth 500 credits."
	worth = 500
	stack = "500 credit chip"

/obj/item/weapon/spacecash/c1000
	name = "1000 credit chip"
	icon_state = "spacecash1000"
	desc = "It's worth 1000 credits."
	worth = 1000
	stack = "1000 credit chip"

proc/spawn_money(var/sum, spawnloc)
	var/cash_type
	for(var/i in list(1000,500,200,100,50,20,10,1))
		cash_type = text2path("/obj/item/weapon/spacecash/c[i]")
		while(sum >= i)
			sum -= i
			new cash_type(spawnloc)
	return