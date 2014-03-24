var/datum/controller/customs_controller/Customs = new()

/datum/controller/customs_controller
	var/global/list/given_enzymes = list()
	var/global/list/given_unique = list()

	var/global/obj/checker = null

/datum/controller/customs_controller/New()
	//world.log << "CUSTOMS CONTROLLER CREATED!"
	if(Customs != src)
		if(istype(Customs))
			del checker
			del(Customs)

	checker = new /obj()
	checker.req_access_txt = "1"

	Customs = src
	Customs.process()

/datum/controller/customs_controller/proc/process()
	spawn(0)
		set background = 1
		var/checked = 0
		var/oldcheck = 0		//Speed up!
		var/area/customs/customs_area = null

		while(1)
			var/list/search = world.contents.Copy()		//Just in case something explodes

			for(var/area/customs/check in search)
				customs_area = check

			//for(var/atom/check in customs_area)
			//	world.log << check.name

			for(var/mob/living/carbon/human/possible_officer in customs_area)	//Monkeys can't be customs officers :(
				if(Customs.checker.allowed(possible_officer))
					if(!possible_officer.restrained() && possible_officer.canmove && !possible_officer.stat)		//So, our possible officer is not handcuffed, can move, a-a-and is actually alive
						//world.log << "FOUND AN OFFICER!"
						checked = 1
						break

			//world.log << "DONE SEARCHING!"
			//world.log << checked

			if(checked != oldcheck)		//I hope this will speed everything up, "for" loops are kinda expensive, after all...
				//world.log << "RE-ENABLED"
				for(var/obj/structure/id_machine/change in search)
					change.enabled = !checked
					if(checked)
						change.icon_state = "id_machine_off"
					else
						change.icon_state = "id_machine_on"
				for(var/obj/structure/id_machine_customs/change in search)
					change.enabled = checked
					if(checked)
						change.icon_state = "id_machine_customs_on"
					else
						change.icon_state = "id_machine_customs_off"
				oldcheck = checked

			checked = 0

			sleep(600)			//~1 min
