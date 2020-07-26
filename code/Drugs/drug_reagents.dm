#define BADTRIP_COOLDOWN 180

// white

/datum/reagent/drug/labebium
	name = "Labebium"
	description = "Пахнет интересно."
	color = "#999922"
	reagent_state = LIQUID
	taste_description = "моча"
	var/obj/effect/hallucination/simple/ovoshi/fruit
	var/obj/effect/hallucination/simple/water/flood
	var/obj/effect/hallucination/simple/ovoshi/statues/statuya
	var/list/trip_types = list("ovoshi", "statues")
	var/current_trip
	var/tripsoundstarted = FALSE
	var/list/shenanigans = list()
	var/list/sounds = list()

/datum/reagent/drug/labebium/on_mob_end_metabolize(mob/living/L)
	stop_shit(L)
	..()

/datum/reagent/drug/labebium/proc/stop_shit(mob/living/carbon/C)
	if(C && C.hud_used)
		if(!HAS_TRAIT(C, TRAIT_DUMB))
			C.derpspeech = 0
		C.cultslurring = 0
		C.hud_used.show_hud(HUD_STYLE_STANDARD)
		C.Paralyze(95)
		DIRECT_OUTPUT(C.client, sound(null))
		var/list/screens = list(C.hud_used.plane_masters["[FLOOR_PLANE]"], C.hud_used.plane_masters["[GAME_PLANE]"], C.hud_used.plane_masters["[LIGHTING_PLANE]"], C.hud_used.plane_masters["[CAMERA_STATIC_PLANE ]"], C.hud_used.plane_masters["[PLANE_SPACE_PARALLAX]"], C.hud_used.plane_masters["[PLANE_SPACE]"])
		for(var/obj/screen/plane_master/whole_screen in screens)
			animate(whole_screen, transform = matrix(), pixel_x = 0, pixel_y = 0, color = "#ffffff", time = 200, easing = ELASTIC_EASING)
			addtimer(VARSET_CALLBACK(whole_screen, filters, list()), 200) //reset filters
			addtimer(CALLBACK(whole_screen, /obj/screen/plane_master/.proc/backdrop, C), 201) //reset backdrop filters so they reappear
		to_chat(C, "<b><big>Неужели отпустило...</big></b>")

		if(C.client && current_cycle > 100)
			to_chat(C, "<b><big>Эта терапия излечила мой аутизм.</big></b>")
			return

		if(prob(50) && current_cycle > 50)
			spawn(30)
				to_chat(C, "<b><big>Или нет?!</big></b>")
				if(prob(50))
					spawn(50)
						to_chat(C, "<b><big>БЛЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯТЬ!!!</big></b>")
						C.reagents.add_reagent_list(list(/datum/reagent/drug/labebium = 25))

/datum/reagent/drug/labebium/proc/create_flood(mob/living/carbon/C)
	for(var/turf/T in orange(14,C))
		if(prob(66))
			if(!(locate(flood) in T.contents))
				flood = new(T, C)

/datum/reagent/drug/labebium/proc/create_ovosh(mob/living/carbon/C)
	for(var/turf/T in orange(14,C))
		if(prob(23))
			if(!(locate(fruit) in T.contents))
				fruit = new(T, C, phrases = shenanigans)

/datum/reagent/drug/labebium/proc/create_statue(mob/living/carbon/C)
	for(var/turf/T in orange(14,C))
		if(prob(1))
			if(!(locate(statuya) in T.contents))
				statuya = new(T, C, phrases = shenanigans)

/datum/reagent/drug/labebium/on_mob_add(mob/living/L)
	. = ..()
	if (!current_trip)
		current_trip = pick(trip_types)
	var/json_file = file("data/npc_saves/Poly.json")
	if(!fexists(json_file))
		return


/datum/reagent/drug/labebium/on_mob_life(mob/living/carbon/H)
	if(!H && !H.hud_used)
		return
	var/high_message
	var/list/screens = list(H.hud_used.plane_masters["[FLOOR_PLANE]"], H.hud_used.plane_masters["[GAME_PLANE]"], H.hud_used.plane_masters["[LIGHTING_PLANE]"], H.hud_used.plane_masters["[CAMERA_STATIC_PLANE ]"], H.hud_used.plane_masters["[PLANE_SPACE_PARALLAX]"], H.hud_used.plane_masters["[PLANE_SPACE]"])
	switch(current_trip)
		if("ovoshi")
			switch(current_cycle)
				if(1 to 20)
					high_message = "БЛЯТЬ! ТОЛЬКО НЕ ОВОЩИ!!!"
					if(prob(30))
						H.derpspeech++
						H.cultslurring++
					if(!tripsoundstarted)
						var/sound/sound = sound('code/Drugs/sounds/cometodaddy.ogg', TRUE)
						sound.environment = 23
						sound.volume = 100
						SEND_SOUND(H.client, sound)
						create_ovosh(H)
						H.hud_used.show_hud(HUD_STYLE_NOHUD)
						H.emote("scream")
						tripsoundstarted = TRUE
				if(31 to INFINITY)
					if(prob(80) && (H.mobility_flags & MOBILITY_MOVE) && !ismovable(H.loc))
						step(H, pick(GLOB.cardinals))
					if(H.client)
						sounds = H.client.SoundQuery()
						for(var/sound/S in sounds)
							if(S.len <= 3)
								PlaySpook(H, S.file, 23)
								sounds = list()
					if(prob(85))
						H.Jitter(35)
						var/rotation = max(min(round(current_cycle/4), 20),360)
						for(var/obj/screen/plane_master/whole_screen in screens)
							if(prob(3))
								var/sound/sound = sound('code/Drugs/sounds/trip_blast.wav')
								sound.environment = 23
								sound.volume = 100
								SEND_SOUND(H.client, sound)
								H.emote("scream")
								H.overlay_fullscreen("labebium", /obj/screen/fullscreen/labeb, rand(1, 23))
								H.clear_fullscreen("labebium", rand(15, 60))
								new /datum/hallucination/delusion(H, TRUE, duration = 150, skip_nearby = FALSE, custom_name = H.name)
								if(prob(50))
									spawn(30)
										H.overlay_fullscreen("labebium", /obj/screen/fullscreen/labeb, rand(1, 23))
										H.clear_fullscreen("labebium", rand(15, 60))
										H.emote("scream")
										if(prob(50))
											spawn(30)
												H.overlay_fullscreen("labebium", /obj/screen/fullscreen/labeb, rand(1, 23))
												H.clear_fullscreen("labebium", rand(15, 60))
												H.emote("scream")
							if(prob(40))
								H.stuttering = 90
								animate(whole_screen, color = color_matrix_rotate_hue(rand(0, 360)), transform = turn(matrix(), rand(1,rotation)), time = 150, easing = CIRCULAR_EASING)
								animate(transform = turn(matrix(), -rotation), time = 100, easing = BACK_EASING)
							if(prob(13))
								H.Jitter(100)
								whole_screen.filters += filter(type="wave", x=20*rand() - 20, y=20*rand() - 20, size=rand()*0.1, offset=rand()*0.5, flags = WAVE_BOUNDED)
								animate(whole_screen, transform = matrix()*2, time = 40, easing = BOUNCE_EASING)
								addtimer(VARSET_CALLBACK(whole_screen, filters, list()), 1200)
							addtimer(VARSET_CALLBACK(whole_screen, filters, list()), 600)
					high_message = "НУ НАХУЙ!!!"
					if(prob(5))
						animate(H.client, pixel_x = rand(-64,64), pixel_y = rand(-64,64), time = 100)
					create_flood(H)
					create_ovosh(H)
		if("statues")
			high_message = "Расслабон..."
			if(!tripsoundstarted)
				var/sound/sound = sound('code/Drugs/sounds/caves8.ogg', TRUE)
				sound.environment = 23
				sound.volume = 80
				SEND_SOUND(H.client, sound)
				H.hud_used.show_hud(HUD_STYLE_NOHUD)
				tripsoundstarted = TRUE
			if(prob(15))
				for(var/obj/screen/plane_master/whole_screen in screens)
					animate(whole_screen, color = color_matrix_rotate_hue(rand(0, 360)), time = rand(5, 20))
			if(prob(15))
				if(H.client)
					sounds = H.client.SoundQuery()
					for(var/sound/S in sounds)
						if(S.len <= 3)
							PlaySpook(H, S.file, 23)
							sounds = list()
				create_statue(H)
				if(prob(3))
					var/sound/sound = sound('code/Drugs/sounds/trip_blast.wav')
					sound.environment = 23
					sound.volume = 100
					SEND_SOUND(H.client, sound)
					H.overlay_fullscreen("labebium", /obj/screen/fullscreen/labeb, rand(1, 23))
					H.clear_fullscreen("labebium", rand(15, 60))
	if(prob(10))
		to_chat(H, "\n")
	if(prob(5))
		to_chat(H, "<b><big>[readable_corrupted_text(high_message)]</big></b>")
	..()

/datum/reagent/drug/labebium/proc/PlaySpook(mob/living/carbon/C, soundfile, environment = 0, vary = TRUE)
	var/sound/sound = sound(soundfile)
	sound.environment = environment //druggy
	sound.volume = rand(25,100)
	if(vary)
		sound.frequency = rand(10000,70000)
	SEND_SOUND(C.client, sound)

/obj/effect/hallucination/simple/water
	name = "ыххыхыхыыы"
	desc = "<big>АААААААААААААААААААААААА!!!</big>"
	image_icon = 'code/Drugs/icons/water.dmi'
	image_state = "water0"
	image_layer = BYOND_LIGHTING_LAYER
	var/triggered_shit = FALSE

/obj/effect/hallucination/simple/water/New(turf/location_who_cares_fuck, mob/living/carbon/C, forced = TRUE)
	image_state = "water[rand(0, 7)]"
	. = ..()
	color = pick("#ff00ff", "#ff0000", "#0000ff", "#00ff00", "#00ffff")
	animate(src, color = color_matrix_rotate_hue(rand(0, 360)), time = 200, easing = CIRCULAR_EASING)
	QDEL_IN(src, rand(40, 200))

/obj/effect/hallucination/simple/water/Crossed(atom/movable/AM)
	. = ..()
	if(!triggered_shit)
		if(ishuman(AM))
			animate(src, pixel_y = 600, pixel_x = rand(-4, 4), time = 30, easing = BOUNCE_EASING)
			if(prob(10) && AM == target)
				var/mob/living/carbon/human/M = AM
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 170)
				to_chat(M, "<b>[readable_corrupted_text("ПШШШШШШШШШШШШШШШШШШШ!!!")]</b>")
				var/sound/sound = sound('code/Drugs/sounds/pshsh.ogg')
				sound.environment = 23
				sound.volume = 20
				SEND_SOUND(M, sound)
				M.Paralyze(25)
			triggered_shit = TRUE


/obj/effect/hallucination/simple/ovoshi
	name = "Овощ"
	desc = "Ммм, заебись."
	image_icon = 'code/Drugs/icons/harvest.dmi'
	image_state = "berrypile"
	var/list/states = list("berrypile", "chilipepper", "eggplant", "soybeans", \
		"plumphelmet", "carrot", "corn", "corn2", "corn_cob", "tomato", "ambrosiavulgaris", \
		"watermelon", "apple", "applestub", "appleold", "lime", "lemon", "poisonberrypile", \
		"grapes", "cabbage", "greengrapes", "orange", "potato", "potato-peeled", "wheat", \
		"ashroom", "cshroom", "eshroom", "fshroom", "amanita", "gshroom", "bshroom", "dshroom", \
		"bezglaznik", "krovnik", "pumpkin", "rice", "goldenapple", "gryab", "curer", "otorvyannik", \
		"glig", "beet", "turnip")
	image_layer = BYOND_LIGHTING_LAYER

/obj/effect/hallucination/simple/ovoshi/New(turf/location_who_cares_fuck, mob/living/carbon/C, forced = TRUE, list/phrases = list())
	image_state = pick(states)
	. = ..()
	SpinAnimation(rand(5, 40), TRUE, prob(50))
	pixel_x = (rand(-16, 16))
	pixel_y = (rand(-16, 16))
	if(prob(1) && C.client)
		if(!phrases.len)
			phrases = list("Мяу", "Кря")
		to_chat(C.client, "<b>[name]</b> <i>говорит</i>, <big>\"[readable_corrupted_text(pick(phrases))]\"</big>")
	animate(src, color = color_matrix_rotate_hue(rand(0, 360)), transform = matrix()*rand(1,3), time = 200, pixel_x = rand(-64,64), pixel_y = rand(-64,64), easing = CIRCULAR_EASING)
	QDEL_IN(src, rand(40, 200))

/obj/effect/hallucination/simple/ovoshi/attack_hand(mob/living/carbon/C)
	if(prob(10))
		to_chat(C, "<b>ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ!!!</b>")
	var/sound/sound = sound(pick('code/Drugs/sounds/wallhit.ogg', \
		'code/Drugs/sounds/wallhit2.ogg', 'code/Drugs/sounds/wallhit3.ogg'))
	sound.environment = 23
	sound.volume = rand(50, 100)
	SEND_SOUND(C.client, sound)
	C.Paralyze(5)
	to_chat(C, "<span class='rose bold'>[prob(50) ? "Получено" : "Потеряно"] [rand(1, 20)] очков преисполнения</span>")
	. = ..()
	qdel(src)

/obj/effect/hallucination/simple/ovoshi/statues
	name = "Мяу"
	desc = "Ого!"
	image_icon = 'code/Drugs/icons/crafts.dmi'
	image_state = "statue1"
	states = list("statue1", "statue2", "statue3", "statue4", \
		"statue6", "statue7", "seangel", "seangel2")

/obj/screen/fullscreen/labeb
	icon = 'code/Drugs/icons/ruzone_went_up.dmi'
	layer = SPLASHSCREEN_LAYER
	plane = SPLASHSCREEN_PLANE
	screen_loc = "CENTER-7,SOUTH"
	icon_state = ""

/obj/item/reagent_containers/pill/labebium
	name = "таблетка правды"
	desc = "Выпей меня."
	icon_state = "pill5"
	list_reagents = list(/datum/reagent/drug/labebium = 15)

/obj/item/storage/pill_bottle/labebium
	name = "бутылочка правды"
	desc = "Поглощение одной такой таблетки превратит тебя в овоща. Я не шучу."

/obj/item/storage/pill_bottle/labebium/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/labebium(src)


