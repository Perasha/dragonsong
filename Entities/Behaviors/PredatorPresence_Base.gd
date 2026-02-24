func execute(entity):	
	#print("PREDATOR'S PRESENCE!")
	var detected_entities = entity.presence.get_overlapping_bodies()
	var i = 0
	for creature in detected_entities:
		#print(creature)
		if creature == self or not creature.is_in_group("entity"):
			if detected_entities.size() > 1:
				GlobalData.array_swapback(detected_entities,i,"Predator Execute")
			else:
				detected_entities.remove_at(0)
		i += 1
	#print(detected_entities)
	for creature in detected_entities:
		if creature.is_in_group("entity"):
			creature.threat = entity
			creature.ResponseSightThreat.execute(creature)
