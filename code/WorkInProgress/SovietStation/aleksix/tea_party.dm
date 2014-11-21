#define TEA_ICON_PATH 'icons/obj/tea.dmi'
/*

/obj/item/weapon/reagent_containers/food/snacks/grown/tea_leaf	//Сухой лист
	icon=TEA_ICON_PATH
	seed="/obj/item/seeds/teaseed"
	name="tea leaf"
	desc="Used to make tea"
	icon_state="tea_leaf"
	//item_state="tea_leaf"
	w_class=1.0
	potency=20
	New()
		..()
		reagents.add_reagent("nutriment",1)	//Чуть питательный чай
		reagents.add_reagent("anti_toxin",1) 	//Антиоксиданты,хех
		spawn(5)
			bitesize=reagents.total_volume/2+1

/obj/item/weapon/tea_dry			//Сухой лист
	name="dry tea leaf"
	icon=TEA_ICON_PATH
	icon_state="dry_leaf"
	//item_state="dry_leaf"			//Иконка в руке
	w_class=1.0

/obj/item/weapon/tea_ground			//Измельчёный лист
	name="ground tea leaf"
	icon=TEA_ICON_PATH
	icon_state="ground_leaf"
	//item_state="ground_leaf"		//Иконка в руке
	w_class=1.0


//Инструменты
/obj/item/weapon/mortar						//Ступка и пестик
	name="mortar and pestle"
	icon=TEA_ICON_PATH
	icon_state="mnp"						//Mortar 'n pestle,сокращаю
	//item_state="mnp"						//Иконка в руке
	w_class=2.0

	attackby(obj/item/W,mob/user)			//Суём туда листья.
		if (istype(W,/obj/item/weapon/tea_dry))	//Проверяем,листья ли это?
			user.drop_item()
			user<<"You grind a leaf!"
			var/obj/item/weapon/tea_ground/GL=new()
			user.put_in_hands(GL)
			del(W)
		else
			user<<"You can't grind this!"

/obj/item/weapon/reagent_containers/food/drinks/teapot
	name="teapot"
	desc="A teapot."
	icon=TEA_ICON_PATH
	icon_state="teapot"
	item_state="teapot"
	amount_per_transfer_from_this=10
	volume=50										//40 чая и 10 воды
	w_class=3.0

	attackby(obj/item/W,mob/user)
		if (istype(W,/obj/item/weapon/tea_ground))
			reagents.add_reagent("tea_liquid",10)
			del(W)

/obj/item/weapon/reagent_containers/food/drinks/cup
	name="tea cup"
	desc="A cup on a small plate."
	icon=TEA_ICON_PATH
	icon_state="cup_empty"
	item_state="cup_empty"
	amount_per_transfer_from_this=5
	volume=30							//Много чая не надо.
	w_class=3.0

	on_reagent_change()					//При изменении кол-ва реагентов
		update_icon()					//Обновляем иконк

	update_icon()
		if (reagents.reagent_list.len>0)
			if (reagents.get_master_reagent_id()=="tea")
				if (reagents.reagent_list.len>1)
					var/hassugar=0					//Проще и красивее
					var/hasmilk=0					//Проще и красивее
					for (var/datum/reagent/R in reagents.reagent_list)
						if (R.id=="milk")			//Молоко всё прячет,для поваров-трейторов
							hasmilk=1
						else if (R.id=="sugar")
							hassugar=1
					if (hasmilk==1)
						name="tea with milk"
						icon_state="cup_tea_milk"
						//item_state="cup_tea_milk"
					else
						if (hassugar==0)			//Сахар тоже всё прячет
							name="tea with additions"
							icon_state="cup_tea_other"
							//item_state="cup_tea_other"
				else
					name="tea"
					icon_state="cup_tea"
					//item_state="cup_tea"
			else									//Не только же чай там может быть?
				icon_state="cup_other"
				//item_state="cup_other"
		else
			name="tea cup"
			icon_state="cup_empty"
			//item_state="cup_empty"

	attackby(obj/item/W,mob/user)
		if (istype(W,/obj/item/weapon/milk_jug))
			if (reagents.total_volume+3<=volume)
				var/obj/item/weapon/milk_jug/Mj=W
				Mj.m_left-=3
				reagents.add_reagent("milk",3)
				Mj.update_icon()
		else if (istype(W,/obj/item/weapon/spoon))
			if (reagents.reagent_list.len>0)
				var/obj/item/weapon/spoon/Sp=W
				if (Sp.full==1)
					if (reagents.total_volume+2<=volume)
						reagents.add_reagent("sugar",2)
						Sp.full=0
						Sp.update_icon()
				else
					user.visible_message("[user.real_name] stirs the tea","You stir the tea")
			else
				user<<"The cup is empty!"
		update_icon()

/obj/item/weapon/milk_jug
	name="milk jug"
	desc="A milk jug."
	icon=TEA_ICON_PATH
	icon_state="milkjug_empty"
	//item_state="mikjug_empty"
	item_state="milkjug"
	w_class=3.0
	var/m_left=0

	update_icon()
		if (m_left>0)
			icon_state="milkjug_milk"
			//item_state="milkjug_milk"
		else
			icon_state="milkjug_empty"
			//item_state="milkjug_empty"

	New()									//Заполняем при создании.
		..()
		m_left=45							//15 порций
		update_icon()

/obj/item/weapon/sugar_bowl
	name="sugar bowl"
	desc="A sugar bowl."
	icon=TEA_ICON_PATH
	icon_state="sugar_empty"
	//item_state="sugar_empty"
	item_state="sugar_bowl"
	w_class=3.0
	var/s_left=0

	attackby(obj/item/W,mob/user)
		if (istype(W,/obj/item/weapon/spoon))
			if (s_left>0)
				var/obj/item/weapon/spoon/S=W
				S.icon_state="spoon_full"
				S.full=1
				s_left-=2
			else
				usr<<"There is no sugar!"
			update_icon()


	update_icon()
		if (s_left>0)
			icon_state="sugar_full"
			//item_state="sugar_full"
		else
			icon_state="sugar_empty"
			//item_state="sugar_empty"

	New()									//Заполняем при создании.
		..()
		s_left=30							//Думаю, что подойдёт,15 порций
		update_icon()

/obj/item/weapon/spoon
	name="tea spoon"
	desc="A silver spoon."
	icon=TEA_ICON_PATH
	icon_state="spoon_empty"
	//item_state="spoon"
	w_class=2.0
	var/full=0

	update_icon()
		if (full==1)
			icon_state="spoon_full"
		else
			icon_state="spoon_empty"


/obj/machinery/stove													//Плита,восстановить нельзя
	name="tea stove"
	desc="Used to heat teapots.Duh."									//Плита для чая.Зачем она нужна?Греть чай.
	icon=TEA_ICON_PATH
	icon_state="stove_empty"
	use_power=1
	active_power_usage=150												//Чуть меньше,чем у фотоко
	anchored=1															//Закреплена на месте
	density=1															//Нельзя пройти сквозь не
	var/state=0															//Состояние
	var/obj/item/weapon/reagent_containers/food/drinks/teapot/T_h=null	//Holder для чайник
	//0-Пусто
	//1-Чайник,выкл.
	//2-Чайник,вкл.

	attackby(obj/item/W,mob/user)
		if (istype(W,/obj/item/weapon/reagent_containers/food/drinks/teapot))
			T_h=W
			user.drop_item()
			W.loc=src
			state=1
		update_icon()

	update_icon()
		if (state==0)
			icon_state="stove_empty"
		else if (state==1)
			icon_state="stove_full_off"
		else
			icon_state="stove_full_on"

	//Упростим жизнь
	attack_hand(mob/user)	//При атаке рукой
		if (state==1)
			detach()		//Снимаем чайник,если он есть и плита выключен

	verb
		turn_on()
			set src in oview(1)
			set name="Turn on"
			if (state==0)
				usr<<"\red There is nothing to heat!"					//Чтобы электричество зря не тратили.
			else if (state==1)
				use_power=2
				state=2
				update_icon()
				while (T_h.reagents.has_reagent("tea_liquid",4) && T_h.reagents.has_reagent("water",1))
					T_h.reagents.remove_reagent("tea_liquid",4)
					T_h.reagents.remove_reagent("water",1)
					T_h.reagents.add_reagent("tea",5)
					sleep(12)											//Не совсем уверен,но чай будет вариться 1 минуту при полной заправке.Нету же смысла ждать кипения не-чая?
				oview()<<"<B>[src]</B> pings!"
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
				state=1
				use_power=1
			else
				usr<<"\red It's already turned on!"
			update_icon()

		detach()
			set src in oview(1)
			set name="Detach the teapot"
			if (state==0)
				usr<<"\red There is nothing to detach!"
			else if (state==2)
				usr<<"\red It's on!You don't want to burn your hands,right?"
			else
				T_h.loc=src.loc
				T_h=null
				state=0
			update_icon()

/obj/machinery/dry_machine												//Сушилк
	name="tea drying machine"
	desc="Used dry tea.Duh."											//Машина для сушки чая.Зачем она нужна?Сушить чай.
	icon=TEA_ICON_PATH													//DRying Machine
	icon_state="drm_empty"
	use_power=1
	active_power_usage=150												//Чуть меньше,чем у фотокопира,также,как у плитк
	anchored=1															//Закреплена на месте
	density=1															//Нельзя пройти сквозь не
	var/state=0															//Состояние
	var/loaded=0														//Сколько чая в сушке?
	//0-Пусто
	//1-Листья,выкл.
	//2-Листья,вкл.
	//Я немного не представляю себе,как такая машина выглядит,а потому делаю её похожей на плитк

	attackby(obj/item/W,mob/user)
		if (istype(W,/obj/item/weapon/reagent_containers/food/snacks/grown/tea_leaf))
			del(W)
			loaded+=10													//Прибавляем 10 к кол-ву чая,сыпать можно бесконечно
			state=1
		update_icon()

	update_icon()
		if (state==0)
			icon_state="drm_empty"
		else if (state==1)
			icon_state="drm_full_off"
		else
			icon_state="drm_full_on"
	verb
		turn_on()
			set src in oview(1)
			set name="Turn on"
			if (state==0)
				usr<<"\red There is nothing to dry!"					//Чтобы электричество зря не тратили.
			else if (state==1)
				use_power=2
				state=2
				update_icon()
				sleep(loaded*10)										//Больше чая-больше сушить! Взято из расчётов в 60 ед. чая-1 мин.
				for (loaded/=10,loaded>0,loaded--)
					new/obj/item/weapon/tea_dry(src.loc)
				state=0
				oview()<<"<B>[src]</B> pings!"
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
				use_power=1
			else
				usr<<"\red It's on already!"
			update_icon()

//Вендомат
/obj/machinery/vending/teamat
	name="\improper Tea Service Vendor"
	desc="A very basic vending machine. Do you want some tea?"
	icon=TEA_ICON_PATH
	icon_state="teamat"
	icon_deny="teamat-deny"			//Если нет доступа,то откажет.Вроде как анимация,см.SecTech
	products=list(/obj/item/weapon/reagent_containers/food/drinks/cup=8,
					/obj/item/weapon/reagent_containers/food/drinks/teapot=2,
					/obj/item/weapon/sugar_bowl=2,
					/obj/item/weapon/milk_jug=2,
					/obj/item/weapon/reagent_containers/food/snacks/candy=5,
					/obj/item/weapon/spoon=6,)		//Ну,не просто же чай хлебать,конфетки положим.
	vend_delay=15
	product_slogans="Tea!;Did you know that our tea contains antioxidants?Yeah,it's healthy for you!;Space is very dangerous...Sit back and enjoy our tea!"
	product_ads="Drink up!;Tea is better!;Care for a cup of tea?;Teapots!!;Have a sip!"
	req_access_txt="25"
*/
//Прочее
/obj/item/clothing/suit/cape
	name="ceremonial cape"
	desc="A cape for your majestic deeds."								//Накидка для ваших королевских нужд.Ну,типа того.
	icon=TEA_ICON_PATH
	icon_state="cape"
	item_state="cape"
	//Не знаю,как на этом будет отображаться кровь.
	body_parts_covered=ARMS												//Прикрывает рук
	allowed=list()														//В накидку ведь ничего нельзя положить?
	armor=list(melee=1,bullet=0,laser=0,energy=0,bomb=0,bio=0,rad=0)	//Пусть будет плотным и немного защищает от ударов!

//При разрушении столы возвращают только детали.
/*
/obj/structure/table/clothed
	icon=TEA_ICON_PATH
	name="clothed table"
	desc="A version of the four legged table. It is clothed."
	icon_state="clothed"

	//Пришлось переписать,т.к. накрыть накрытый стол нельзя,а при поломке он возвращал бы скатерть
	//Замечу,что при поломке пришельцем/халком/сильным животным скатерть не остаётся
	//1.Лень
	//2.В случае ксено и животного,кажется,есть смыс
	attackby(obj/item/weapon/W, mob/user)
		if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
			var/obj/item/weapon/grab/G = W
			if (istype(G.affecting, /mob/living))
				var/mob/living/M = G.affecting
				if (G.state < 2)
					if(user.a_intent == "hurt")
						if (prob(15))	M.Weaken(5)
						M.apply_damage(8,def_zone = "head")
						visible_message("\red [G.assailant] slams [G.affecting]'s face against \the [src]!")
						playsound(src.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
					else
						user << "\red You need a better grip to do that!"
						return
				else
					G.affecting.loc = src.loc
					G.affecting.Weaken(5)
					visible_message("\red [G.assailant] puts [G.affecting] on \the [src].")
				del(W)
				return

		if (istype(W, /obj/item/weapon/wrench))
			user << "\blue Now disassembling table"
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user,50))
				destroy()
			return

		if(isrobot(user))
			return

		if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(src.loc, "sparks", 50, 1)
			for(var/mob/O in viewers(user, 4))
				O.show_message("\blue The [src] was sliced apart by [user]!", 1, "\red You hear [src] coming apart.", 2)
			destroy()

		user.drop_item(src)
		return

/obj/structure/table/reinforced/clothed
	icon=TEA_ICON_PATH
	name="clothed reinforced table"
	desc="A strong four legged table. It is clothed."
	icon_state="clothed"								//Думаю,разницу делать не имеет смысла.
	status=2

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0, user))
				if(src.status == 2)
					user << "\blue Now weakening the reinforced table"
					playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
					if (do_after(user, 50))
						if(!src || !WT.isOn()) return
						user << "\blue Table weakened"
						src.status = 1
				else
					user << "\blue Now strengthening the reinforced table"
					playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
					if (do_after(user, 50))
						if(!src || !WT.isOn()) return
						user << "\blue Table strengthened"
						src.status = 2
				return
			return

		if (istype(W, /obj/item/weapon/wrench))
			if(src.status == 2)
				return

		..()


/obj/structure/table/woodentable/clothed
	icon=TEA_ICON_PATH
	name="clothed wooden table"
	icon_state="clothed_wood"
*/
/*
/obj/item/weapon/storage/bag/tea
	name="Box of tea"
	desc="You can store some tea there!."
	icon_state="box"
	item_state="box"
	allow_quick_gather=1						//Можно быстро собирать чай!
	w_class=3
	storage_slots=16							//4 порции сухого чая.Думаю,что честно.
	can_hold=list("/obj/item/weapon/reagent_containers/food/snacks/grown/tea_leaf","/obj/item/weapon/tea_ground","/obj/item/weapon/tea_dry")

	New()										//При создании такой коробк
		..()									//Создаём объект
		for (var/c=1,c<16,c++)		//Цикл для заполнения
			new/obj/item/weapon/tea_ground(src)	//Заполняем чаем


/obj/item/weapon/cloth
	icon=TEA_ICON_PATH
	name="white tablecloth"
	desc="A beautiful white tablecloth!"
	icon_state="cloth"
	item_state="cloth_roll"
	force=0
	flags=FPRINT | TABLEPASS
	var/cloth_left=4									//На 4 сто

	proc
		clothtab()
			cloth_left--
			if (cloth_left==0)
				del(src)


/datum/supply_packs/tea
	name="Ceremonial tea crate"
	contains=list(/obj/item/clothing/suit/cape,		//Плащ
					/obj/item/weapon/cloth,				//4 рулоноа скатерт
					/obj/item/weapon/cloth,
					/obj/item/weapon/cloth,
					/obj/item/weapon/cloth,
					/obj/item/weapon/storage/bag/tea)	//4 порции чая
	cost=10
	containertype=/obj/structure/closet/crate
	containername="Tea crate"
	group="Hospitality" */