import json
import os
import numpy as np
import matplotlib.pyplot as plt
from util import *
from get_scores import getScores
from recognition import *
from new_recognition import *

# Image directory
dir = 'images_winebottles\\test\\'

# List of bottles names
gtImages = importDataset('gt')
bottlesNames = []
for i in range(len(gtImages)):
    bottlesNames.append(extractFileName(gtImages[i], -1))

#rawImages = importDataset('raw')
#bottlesImages = importDataset('bottles')
#print(len(rawImages))
#print(len(bottlesImages))
#print(len(gtImages))

command = ''
while command != 'quit':
    # Ask for image name
    command = input('\nEnter the name of an image in \'images_winebottles\\test\' or \'quit\': ')
    print()
    if command == 'quit':
        break
    if '.' not in command:
        print('Image\'s name miss file extension.')
        continue

    # Call recognition process
    image = dir + command
    response = new_recognition([image])
    if response == 0:
        break

    # Create .json file if it doesn't exist
    index = image.find('.')
    filename = image[:index] + '_NEW.json'
    exists = os.path.isfile(filename)
    if not exists:
        print(filename + 'doesn\'t exists. Something went wrong...' )
        break

    # Else get recognition results for image
    else:
        # Open file with results of image
        with open(filename, 'r') as file:
            jsonBottle = json.load(file)
        # Copy all words found
        wordsBottle = []
        for word in jsonBottle['words']:
            if word not in wordsBottle:
                    wordsBottle.append(word)

    # Print the name of the bottle
    scores = getScores(wordsBottle)
    indexSort = np.argsort(scores)
    #print(scores)
    indexRank = np.argmin(scores)
    bottlesNames = np.asarray(bottlesNames)
    rank = bottlesNames[indexRank]
    sort = bottlesNames[indexSort]
    print('\nSorting bottles for similarities with the chosen one:\n', sort)
    print('\nThe name of the bottle is: ', rank)
    print()
