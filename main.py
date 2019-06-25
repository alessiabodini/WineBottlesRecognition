import json
import os
import numpy as np
import matplotlib.pyplot as plt
from util import *
from get_scores import getScores
from recognition import *

# Image directory
dir = 'images_winebottles\\text\\'

# Import information from bottles
wordsInBottles = importBottles()
wordsInBottles = np.array(wordsInBottles)

# List of bottles names
gtImages = importDataset('gt')
bottlesNames = []
for i in range(len(gtImages)):
    bottlesNames.append(extractFileName(gtImages[i], -1))

command = ''
while command != 'quit':
    # Ask for image name
    command = input('Enter the name of an image in \'images_winebottles\\text\': ')
    if command == 'quit':
        break
    if '.' not in command:
        print('Image\'s name miss file extension.')
        continue

    # Call recognition process
    image = dir + command
    response = recognition([image])
    if response == 0:
        break

    # Create .json file if it doesn't exist
    index = image.find('.')
    filename = image[:index] + '.json'
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
        for words in jsonBottle['recognitionResult']['lines']:
            for word in words['words']:
                if word['text'] not in wordsBottle:
                    wordsBottle.append(word['text'])

        print(wordsBottle)

    # Print the name of the bottle
    scores = getScores(wordsBottle)
    indexRank = np.argmax(scores)
    bottlesNames = np.asarray(bottlesNames)
    rank = bottlesNames[indexRank]
    print(rank)
