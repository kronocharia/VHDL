import random

numCommands = 10000
with open("randomcommands.txt", "w+") as fo:

	for i in range(numCommands):

		rand_command = random.choice(['D','C'])
		rand_colour = random.choice(['W','B','I'])
		rand_xCoor = random.randint(0,2**6)
		rand_yCoor = random.randint(0,2**6)


		# print rand_command+rand_colour, rand_xCoor, rand_yCoor
		fo.write(rand_command+rand_colour+" "+str(rand_xCoor)+" "+str(rand_yCoor)+'\n')

print "test file created"