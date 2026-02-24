func execute(entity):
	print("ATTACK TARGET!")
	print(entity.name)
	#print(entity.attacking_entity)
	entity.thought = entity.ATTACK
	entity.attack_target = entity.attacking_entity
	pass
