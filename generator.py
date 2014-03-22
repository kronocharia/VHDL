import random

numCommands = 50000
pen = (0, 0)
with open("randomcommands.txt", "w+") as fo:
	for i in range(numCommands):
		rand_command = random.choice(['D','C','M'])
		rand_colour = random.choice(['W','B','I'])
		if (rand_command == 'C'):
			rand_xCoor = random.randint(pen[0],63)
			rand_yCoor = random.randint(pen[1],63)
		else:
			rand_xCoor = random.randint(0,63)
			rand_yCoor = random.randint(0,63)
		pen = (rand_xCoor, rand_yCoor)

		# print rand_command+rand_colour, rand_xCoor, rand_yCoor
		fo.write(rand_command+rand_colour+" "+str(rand_xCoor)+" "+str(rand_yCoor)+'\n')

print "test file created"