func execute(entity):
	#print("FLEE!")
	#print(entity.attacking_entity)
	#entity.is_running = true
	if entity.attacking_entity:
		entity.threat = entity.attacking_entity
	if entity.threat == null:
		entity.thought = entity.IDLE
	else:
		entity.thought = entity.FLEE
		entity.is_running = true
