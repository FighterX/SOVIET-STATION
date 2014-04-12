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

/obj/item/weapon/spacecash/cashstack
	name = "Cash stack"
	worth = 1
	desc = "It's worth 1 credits."
	icon_state = "spacecash"

/obj/item/weapon/spacecash/cashstack/proc/update_cash_icon()
	desc = "It's worth [worth] credits."
	if(worth>1000)
		icon_state = "spacecash1000"
		return
	if(worth>500)
		icon_state = "spacecash500"
		return
	if(worth>200)
		icon_state = "spacecash200"
		return
	if(worth>100)
		icon_state = "spacecash100"
		return
	if(worth>50)
		icon_state = "spacecash50"
		return
	if(worth>20)
		icon_state = "spacecash20"
		return
	if(worth>10)
		icon_state = "spacecash10"
		return
	if(worth>1)
		icon_state = "spacecash"
		return
	icon_state = "spacecash"

obj/item/weapon/spacecash/cashstack/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

obj/item/weapon/spacecash/cashstack/attackby(obj/item/weapon/spacecash/cashstack/C, mob/living/user)
	..()
	if(istype(C, /obj/item/weapon/spacecash/cashstack/))
		var/obj/item/weapon/spacecash/cashstack/D = C
		worth += D.worth
		user.u_equip(D)
		del(D)
		desc = "It's worth [worth] credits."
		update_cash_icon()


obj/item/weapon/spacecash/cashstack/interact(mob/user)
	var/dat = "Cash stack worth [worth] credits.<BR>"
	if(worth>1000)
		dat += "<A href='?src=\ref[src];worth=1000'>1000</A>"
	if(worth>500)
		dat += "<A href='?src=\ref[src];worth=500'>500</A>"
	if(worth>200)
		dat += "<A href='?src=\ref[src];worth=200'>200</A>"
	if(worth>100)
		dat += "<A href='?src=\ref[src];worth=100'>100</A>"
	if(worth>50)
		dat += "<A href='?src=\ref[src];worth=50'>50</A>"
	if(worth>20)
		dat += "<A href='?src=\ref[src];worth=20'>20</A>"
	if(worth>10)
		dat += "<A href='?src=\ref[src];worth=10'>10</A>"
	if(worth>1)
		dat += "<A href='?src=\ref[src];worth=1'>1</A>"
	if(worth == 1)
		dat += "It's better than nothing...<BR>"
	var/datum/browser/popup = new(user, "cashstack", "Stack of Cash", 300, 150)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()

obj/item/weapon/spacecash/cashstack/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/moneyUser = usr
	if(href_list["worth"])
		if (moneyUser.get_active_hand() == src || moneyUser.get_inactive_hand() == src)
			var/choice = max(text2num(href_list["worth"]),0)
			worth-=choice
			update_cash_icon()
			var/obj/item/weapon/spacecash/cashstack/C = new /obj/item/weapon/spacecash/cashstack(moneyUser.loc)
			C.worth = choice
			C.update_cash_icon()
			C.pickup(moneyUser)
			moneyUser.put_in_any_hand_if_possible(C)
			interact(moneyUser)
		return

/obj/item/weapon/spacecash/c1
	name = "1 credit chip"
	icon_state = "spacecash"
	desc = "It's worth 1 credit."
	worth = 1

/obj/item/weapon/spacecash/c10
	name = "10 credit chip"
	icon_state = "spacecash10"
	desc = "It's worth 10 credits."
	worth = 10

/obj/item/weapon/spacecash/c20
	name = "20 credit chip"
	icon_state = "spacecash20"
	desc = "It's worth 20 credits."
	worth = 20

/obj/item/weapon/spacecash/c50
	name = "50 credit chip"
	icon_state = "spacecash50"
	desc = "It's worth 50 credits."
	worth = 50

/obj/item/weapon/spacecash/c100
	name = "100 credit chip"
	icon_state = "spacecash100"
	desc = "It's worth 100 credits."
	worth = 100

/obj/item/weapon/spacecash/c200
	name = "200 credit chip"
	icon_state = "spacecash200"
	desc = "It's worth 200 credits."
	worth = 200

/obj/item/weapon/spacecash/c500
	name = "500 credit chip"
	icon_state = "spacecash500"
	desc = "It's worth 500 credits."
	worth = 500

/obj/item/weapon/spacecash/c1000
	name = "1000 credit chip"
	icon_state = "spacecash1000"
	desc = "It's worth 1000 credits."
	worth = 1000

proc/spawn_money(var/sum, spawnloc)
	var/mob/living/carbon/human/moneyUser = usr
	var/obj/item/weapon/spacecash/cashstack/C = new /obj/item/weapon/spacecash/cashstack(moneyUser.loc)
	C.worth = sum
	C.update_cash_icon()
	C.pickup(moneyUser)
	moneyUser.put_in_any_hand_if_possible(C)
	return