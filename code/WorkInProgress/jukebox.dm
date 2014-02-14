/obj/machinery/jukebox
	name = "jukebox"
	icon_state = "jukebox_off"
	anchored = 1
	density = 1
	use_power = 1
	active_power_usage = 100
	idle_power_usage = 50
	power_channel = EQUIP
	var/trackname="None"
	var/list/tracks=list()
	var/list/music_area=list()
	var/sound/curtrack
	var/list/canhear=list()
	var/vol=30	//default

/obj/machinery/jukebox/proc/update_tracks()
	var/list/track_files=flist("sound/specmusic/")
	tracks=list()
	if(track_files!=null && track_files.len>0)
		for(var/c=1,c<=track_files.len,c++)
			var/parsed=replacetext(copytext(track_files[c],1),".ogg","")
			parsed=replacetext(copytext(parsed,1),"_"," ")
			tracks[parsed]=track_files[c]
	else
		tracks["None"]="None"

/obj/machinery/jukebox/New()
	..()
	update_tracks()
	update_icon()
	canhear=ohearers(10,loc)
	juke_process()

/obj/machinery/jukebox/attack_hand(mob/user)
	user.set_machine(src)
	var/dat = "<HTML><HEAD><TITLE>Jukebox Controls</TITLE></HEAD><BODY>"

	dat += "<CENTER><B>Current track:<B>[trackname]</CENTER><BR>"
	dat += "<BR>"
	dat += "Volume:<BR>"
	dat += "<A href='?src=\ref[src];vol=1'>++</A>"
	dat += "<A href='?src=\ref[src];vol=-1'>--</A><BR>"
	dat += "<BR>"
	dat += "<A href='?src=\ref[src];change_track=1'>Change track<A><BR>"

	if(use_power == 1)
		dat += "<A href='?src=\ref[src];play=1'>Play</A><BR>"
		dat += "<B>Stop<B><BR>"
	else if(use_power == 2)
		dat += "<A href='?src=\ref[src];stop=1'>Stop</A><BR>"
		dat += "<B>Play</B><BR>"

	dat += "</BODY></HTML>"
	user << browse(dat,"window=jukebox")
	onclose(user,"jukebox")

/obj/machinery/jukebox/update_icon()
	if(stat&NOPOWER)
		icon_state="jukebox_off"
		SetLuminosity(0)
		use_power=0
		canhear<<sound(null,channel=1000)
	else
		if(use_power==2)
			icon_state="jukebox_on"
			SetLuminosity(3)
		else
			icon_state="jukebox_off"
			SetLuminosity(0)

/obj/machinery/jukebox/Topic(href,href_list)
	if(href_list["vol"])
		if(href_list["vol"]=="1")
			if(vol+10<=70)
				vol+=10
		else if(href_list["vol"]=="-1")
			if(vol-10>=0)
				vol-=10
		if(use_power==2)
			curtrack.volume=vol
	if(href_list["change_track"])
		if(tracks.len>0 && tracks["None"]!="None")
			trackname=input(usr,"Tracks:","Change track") in tracks
			if(!trackname)
				trackname="None"
	else if(href_list["play"])
		if(trackname!="None")
			canhear<<sound(null,channel=1000)
			curtrack=sound("sound/specmusic/[tracks[trackname]]",volume=vol,channel=1000)
			use_power=2
			update_icon()
	else if(href_list["stop"])
		hearers()<<sound(null,channel=1000)
		use_power=1
		update_icon()

	src.updateUsrDialog()

/obj/machinery/jukebox/proc/juke_process()
	spawn(15)							//Instead of processing every tick,it processes once every 1,5 seconds
		if(use_power==2)
			if(canhear.len>0)
				curtrack.status=SOUND_MUTE | SOUND_UPDATE
				canhear<<curtrack
			canhear=ohearers(10,loc)
			if(canhear.len>0)
				curtrack.status=SOUND_UPDATE
				canhear<<curtrack
		update_icon()
		juke_process()