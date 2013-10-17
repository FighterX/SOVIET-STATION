/*
	Trains,by aleksix
	Usage:place rails,place stoppoints,then place the first part of the train(/obj/machinery/train/leading) and set its "dir" variable
	The train consists of 4 parts:Leading part,cargo part and 2 passenger parts ((Dunno how to name 'em)
	Constants:
		STOP_TIME - For how long will it stop
		DEF_POWER - Emergency power.When area is not powered,The train will use its own battery
*/

#define STOP_TIME 30 //In seconds
#define DEF_POWER 30 //In tiles

/obj/train_stop
	name = "train stop"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x3"
	anchored = 1
	unacidable = 1
	invisibility = 100
	var/stop_name = ""		//Name to announce
	var/done = 0

/*
	Rails are harder
	Rail icon is one half of the rail
	Junction is the thing between two rails
*/
/obj/structure/rail
	anchored = 1
	icon='obj/trains.dmi'
	icon_state="rail_ico"		//Just to see it
	var/dir1
	var/dir2

/obj/structure/rail/New()
	..()
	update_icon()

/obj/structure/rail/update_icon()
	if(dir1==dir2)
		del(src)
		return
	var/n=0
	var/s=0
	var/e=0
	var/w=0
	var/icon/I=icon('obj/trains.dmi',"rail")
	switch(dir1)
		if(NORTH)
			n=1
			I.Turn(180)
		if(SOUTH)
			s=1
		if(EAST)
			e=1
			I.Turn(-90)
		if(WEST)
			w=1
			I.Turn(90)
	var/icon/I2=icon('obj/trains.dmi',"rail")
	switch(dir2)
		if(NORTH)
			n=1
			I2.Turn(180)
		if(SOUTH)
			s=1
		if(EAST)
			e=1
			I2.Turn(-90)
		if(WEST)
			w=1
			I2.Turn(90)
	I.Blend(I2,ICON_UNDERLAY)
	if(!((n && s) || (e && w)))
		var/icon/I3=icon('obj/trains.dmi',"rail_junc")
		if(n && w)
			I3.Flip(NORTH)
		else if(s && e)
			I3.Flip(EAST)
		else if(e)
			I3.Flip(EAST)
			if(n)
				I3.Flip(NORTH)
		I.Blend(I3,ICON_OVERLAY)
	icon=I


/obj/structure/rail/vertical
	dir1 = NORTH
	dir2 = SOUTH

/obj/structure/rail/horizontal
	dir1 = EAST
	dir2 = WEST

/obj/structure/rail/NW
	dir1 = NORTH
	dir2 = WEST

/obj/structure/rail/SW
	dir1 = SOUTH
	dir2 = WEST

/obj/structure/rail/NE
	dir1 = NORTH
	dir2 = EAST

/obj/structure/rail/SE
	dir1 = SOUTH
	dir2 = EAST

/obj/machinery/train
	icon='obj/trains.dmi'
	density = 1
	anchored = 1
	var/obj/machinery/train/connected_to
	var/capacity = 0				//How many things can this part hold
	var/holds = 0					//How many things does it hold
	var/prev_loc					//For moving connected train parts
	var/doors = 1

/obj/machinery/train/attackby(obj/item/weapon/O as obj, mob/user as mob)
	if(doors==0)
		if(istype(O,/obj/item/weapon/crowbar))
			doors = 1
			if(prob(75))
				user << "\green You managed to open the door"
			else
				user << "\red You failed to open the door"
	else
		user << "\blue The door's motors resist your efforts to force it."

/obj/machinery/train/New()
	..()
	prev_loc=locate(x,y,z)

/obj/machinery/train/Move(new_loc, dir)
	..()
	if(connected_to)
		step_to(connected_to,prev_loc)
	prev_loc=new_loc

	var/dx=0
	var/dy=0
	switch(dir)
		if(NORTH)
			dy=1
		if(SOUTH)
			dy=-1
		if(EAST)
			dx=1
		if(WEST)
			dx=-1
	for(var/mob/living/V in locate(x+dx,y+dy,z))
		if(istype(V,/mob/living/carbon/human))
			var/mob/living/carbon/human/H=V
			var/dam_zone = pick("chest", "chest", "l_hand", "r_hand", "l_leg", "r_leg")		//Chest is rather big,higher chance of smashing!
			var/datum/organ/external/affecting = H.get_organ(ran_zone(dam_zone))
			H.apply_damage(rand(25,60), BRUTE, affecting, H.run_armor_check(affecting, "melee"),"Train")	//I think that melee armor must protect from brute damage,right?
		else
			V.apply_damage(rand(25,60))
		V.Weaken(10)

/obj/machinery/train/leading
	name = "Leading part"
	icon_state = "leading"
	use_power = 1
	var/is_on = 0					//Is it on?
	var/stopped = 0					//Will it move?
	var/emergency_power = DEF_POWER		//How many tiles it will move before turning off
	capacity = 1

/obj/machinery/train/leading/proc/opposite(var/dir)
	switch(dir)
		if(NORTH)
			return SOUTH
		if(SOUTH)
			return NORTH
		if(EAST)
			return WEST
		if(WEST)
			return EAST

/obj/machinery/train/leading/proc/train_process()
	spawn(5)
		if(!stopped && is_on)
			var/obj/structure/rail/connected = locate(/obj/structure/rail) in src.loc
			if(connected)
				if(dir==opposite(connected.dir1))
					step(src,connected.dir2)
				else if(dir==opposite(connected.dir2))
					step(src,connected.dir1)
		train_process()

/obj/machinery/train/leading/proc/showmenu(var/mob/M as mob)
	M.set_machine(src)
	var/menu = "<HTML><HEAD><TITLE>Train Controls</TITLE></HEAD><BODY>"
	menu += "<CENTER><B>State:<B>[is_on ? "ON" : "OFF"]</CENTER><BR>"
	menu += "<BR>"
	if(is_on)
		menu += "<A href='?src=\ref[src];off=1'>Stop</A><BR>"
	else
		menu += "<A href='?src=\ref[src];on=1'>Start</A><BR>"
	menu += "<B>Emergency battery:</B>[emergency_power]<BR>"
	menu += "</BODY></HTML>"
	M << browse(menu,"window=leadingtrain;can_close=0")
	onclose(M,"leadingtrain",src)

/obj/machinery/train/leading/New()
	..()
	var/dx=0
	var/dy=0
	switch(dir)
		if(NORTH)
			dy=-1
		if(SOUTH)
			dy=1
		if(EAST)
			dx=-1
		if(WEST)
			dx=1
	var/obj/machinery/train/cargo/c=new(locate(x+dx,y+dy,z))
	var/obj/machinery/train/passenger/p1=new(locate(x+dx+1*dx,y+dy+1*dy,z))
	var/obj/machinery/train/passenger/p2=new(locate(x+dx+2*dx,y+dy+2*dy,z))
	p1.connected_to = p2
	c.connected_to = p1
	connected_to = c
	train_process()

/obj/machinery/train/leading/Move(new_loc, dir)
	//if(!stop)
	var/dx=0
	var/dy=0
	switch(dir)
		if(NORTH)
			dy=1
		if(SOUTH)
			dy=-1
		if(EAST)
			dx=1
		if(WEST)
			dx=-1
	var/obj/structure/rail/R=locate(/obj/structure/rail) in locate(x+dx,y+dy,z)
	if(R)
		var/obj/train_stop/stop=locate(/obj/train_stop) in locate(x+dx,y+dy,z)
		if(stop)
			if(!stop.done)
				for(var/mob/O in hearers(src, null))
					O.show_message("<span class='game say'><span class='name'>Train speaker</span> announces, \"[stop.stop_name]\"",2)
				var/obj/machinery/train/T=src
				while(T)
					for(var/mob/O in T.contents)
						O.show_message("<span class='game say'><span class='name'>Train speaker</span> announces, \"[stop.stop_name]\"",2)
					T=T.connected_to
				stopped=1
				stop.done=1
				spawn(STOP_TIME*10)
					stopped=0
				spawn(STOP_TIME*10+20)
					stop.done=0
				return
		if(powered())
			..()
			if(emergency_power<DEF_POWER)			//Restore some power.Just in case
				use_power(400)
				emergency_power++
			use_power(500)
		else if(emergency_power>0)
			..()
			emergency_power--
			for(var/mob/M in contents)
				showmenu(M)
			if(emergency_power<15)
				doors=0
				var/obj/machinery/train/cur=connected_to
				while(cur)
					cur.doors=0
					cur=cur.connected_to

/obj/machinery/train/leading/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(!istype(M)) return
	if(doors)
		if(holds<capacity)
			holds++
			contents += M
			showmenu(M)
	else
		user<<"\red The door doesn't open!"

/obj/machinery/train/leading/Topic(href,href_list)
	if(href_list["on"])
		is_on=1
		//src.updateUsrDialog()
	else if(href_list["off"])
		is_on=0
	showmenu(usr)
	//Somehow,THIS dialog doesn't want to update


/obj/machinery/train/leading/relaymove(mob/user, direction)
	var/dx=0		//Direction x
	var/dy=0		//Direction y
	switch(direction)
		if(NORTH)
			dy=1
		if(SOUTH)
			dy=-1
		if(EAST)
			dx=1
		if(WEST)
			dx=-1
	var/atom/I=locate(x+dx,y+dy,z)
	if(I.density)
		return
	if(istype(user) && user in contents)
		if(!doors)
			if(!prob(15))
				user<<"\red The door won't budge!"
				return
		user.loc=src.loc
		user.Move(locate(x+dx,y+dy,z),direction)
		holds--
		user << browse(null, "window=leadingtrain")

/obj/machinery/train/cargo
	name = "Cargo part"
	icon_state="cargo"
	capacity=6

/obj/machinery/train/cargo/MouseDrop_T(obj/structure/closet/O as obj, mob/user as mob)
	if(!istype(O)) return
	if(doors)
		if(holds<capacity)
			holds++
			contents+=O
	else
		user<<"\red The door doesn't open!"

/obj/machinery/train/cargo/attack_hand(mob/user as mob)
	//The doors in cargo part are much bigger,so they are harder to open
	if(doors)
		user.set_machine(src)
		var/menu = "<HTML><HEAD><TITLE>Cargo</TITLE></HEAD><BODY>"
		menu += "<HR>"
		for(var/obj/structure/closet/O in src)
			menu += "<A href='?src=\ref[src];remove=\ref[O]'>Remove</A> - [O.name]<BR>"
		menu += "</BODY></HTML>"
		user<<browse(menu,"window=cargotrain")
		onclose(user,"cargotrain")
		add_fingerprint(user)
	else
		user<<"\red The door won't budge!"

/obj/machinery/train/cargo/Topic(href, href_list)
	..()

	if((usr.stat || usr.restrained()))
		return

	if(href_list["remove"])
		var/obj/structure/closet/O = locate(href_list["remove"])
		if(O)
			O.loc = src.loc
			holds--
	attack_hand(usr)

/obj/machinery/train/passenger
	name = "Passenger part"
	icon_state = "passenger"
	capacity = 6

/obj/machinery/train/passenger/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(!istype(M)) return
	if(doors)
		if(holds<capacity)
			holds++
			contents += M
	else
		user<<"\red The door doesn't open!"

/obj/machinery/train/passenger/relaymove(mob/user, direction)
	if(doors == 1)
		var/dx=0		//Direction x
		var/dy=0		//Direction y
		switch(direction)
			if(NORTH)
				dy=1
			if(SOUTH)
				dy=-1
			if(EAST)
				dx=1
			if(WEST)
				dx=-1
		var/atom/I=locate(x+dx,y+dy,z)
		if(I.density)
			return
		if(istype(user) && user in contents)
			if(!doors)
				if(!prob(15))
					user<<"\red The door won't budge!"
					return
			user.loc=src.loc
			user.Move(locate(x+dx,y+dy,z),direction)
			holds--