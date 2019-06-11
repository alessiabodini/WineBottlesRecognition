import json
import os
import numpy as np
import matplotlib.pyplot as plt
from util import *
from recognition import *
from pyxdameraulevenshtein import *

# Image directory
dir = 'images_winebottles\\text\\'

# Import information from bottles
wordsInBottles = importBottles()
wordsInBottles = np.array(wordsInBottles)

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
    recognition([image])

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

        #print(wordsBottle)

    # SCORES PART TO COMPLETE
    scores = np.zeros([len(wordsInBottles)])
    print(scores)
    #for word in wordsBottle:
    #    damerau_levenshtein_distance_ndarray(word,)
