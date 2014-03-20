var/datum/controller/customs_controller/Customs = new()

/datum/controller/customs_controller
	var/list/given_enzymes = list()
	var/list/given_unique = list()

	var/list/id_machines = list()
	var/list/id_machines_customs = list()

	var/obj/checker = null

	var/area/customs_area

/datum/controller/customs_controller/New()
	//world.log << "CUSTOMS CONTROLLER CREATED!"
	if(Customs != src)
		if(istype(Customs))
			del(Customs)

	checker = new/obj()
	checker.req_access_txt = "1"

	Customs = src
	Customs.process()

/datum/controller/customs_controller/proc/process()
	spawn(0)
		set background = 1
		var/checked = 0

		while(1)
			var/list/search = world.contents.Copy()
			for(var/area/customs/check in search)
				if(istype(check))
					Customs.customs_area = check
					//break

			//for(var/atom/check in Customs.customs_area)
			//	world.log << check.name

			for(var/mob/living/carbon/human/possible_officer in Customs.customs_area)	//Monkeys can't be customs officers :(
				if(Customs.checker.allowed(possible_officer))
					//world.log << "FOUND AN OFFICER!"
					checked = 1
					break

			//world.log << "DONE SEARCHING!"
			world.log << checked
			for(var/obj/structure/id_machine/change in search)
				change.enabled = !checked
			for(var/obj/structure/id_machine_customs/change in search)
				change.enabled = checked

			checked = 0

			sleep(600)			//~1 min
