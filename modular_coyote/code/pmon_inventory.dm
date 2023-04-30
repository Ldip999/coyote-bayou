
/////////////////////
//Pokemon INVENTORY//
/////////////////////
//Pokemon inventory
//Pokemon hands

/mob/living/simple_animal/pokemon/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used && hud_used.hud_shown)
		internal_storage.screen_loc = ui_drone_storage
		client.screen += internal_storage

/mob/living/simple_animal/pokemon/update_inv_head()
	if(head)
		if(client && hud_used && hud_used.hud_shown)
			head.screen_loc = ui_drone_head
			client.screen += head

/mob/living/simple_animal/pokemon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE)
	if(..())
		update_inv_hands()
		if(I == head)
			head = null
			update_inv_head()
		if(I == internal_storage)
			internal_storage = null
			update_inv_internal_storage()
		return 1
	return 0


/mob/living/simple_animal/pokemon/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, clothing_check = FALSE, list/return_warning)
	switch(slot)
		if(SLOT_HEAD)
			if(head)
				return 0
			if(!((I.slot_flags & ITEM_SLOT_HEAD) || (I.slot_flags & ITEM_SLOT_MASK)))
				return 0
			return 1
		if(SLOT_GENERC_DEXTROUS_STORAGE)
			if(internal_storage)
				return 0
			return 1
	..()


/mob/living/simple_animal/pokemon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(SLOT_HEAD)
			return head
		if(SLOT_GENERC_DEXTROUS_STORAGE)
			return internal_storage
	return ..()


/mob/living/simple_animal/pokemon/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return
	if(!istype(I))
		return

	var/index = get_held_index_of_item(I)
	if(index)
		held_items[index] = null
	update_inv_hands()

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.screen_loc = null // will get moved if inventory is visible
	I.forceMove(src)
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE

	switch(slot)
		if(SLOT_HEAD)
			head = I
			update_inv_head()
		if(SLOT_GENERC_DEXTROUS_STORAGE)
			internal_storage = I
			update_inv_internal_storage()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))
			return

	//Call back for item being equipped to pokemon
	I.equipped(src, slot)

/mob/living/simple_animal/pokemon/getBackSlot()
	return SLOT_GENERC_DEXTROUS_STORAGE

/mob/living/simple_animal/pokemon/getBeltSlot()
	return SLOT_GENERC_DEXTROUS_STORAGE

/mob/living/simple_animal/pokemon/examine(mob/user)
	. = list("<span class='info'>*---------*\nThis is [icon2html(src, user)] \a <b>[src]</b>!")

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags))
			. += "It has [I.get_examine_string(user)] in its [get_held_index_name(get_held_index_of_item(I))]."

	//Internal storage
	if(internal_storage && !(internal_storage.item_flags))
		. += "It is holding [internal_storage.get_examine_string(user)] in its internal storage."

	//Cosmetic hat - provides no function other than looks
	if(head && !(head.item_flags))
		. += "It is wearing [head.get_examine_string(user)] on its head."
