func execute(entity):
	print("ALERT NEARBY ENTITIES!")
	print(entity.attacking_entity)
	#entity.is_running = true
	entity.thought = entity.FLEE
	entity.threat = entity.attacking_entity
	entity.is_running = true
	pass
