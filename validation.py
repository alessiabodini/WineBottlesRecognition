import json
import os
import numpy as np
from util import importDataset

# Images' directories
gtDir = 'images_winebottles\\gt\\'
bottlesDir = 'images_winebottles\\bottles\\'


bottlesImages = importDataset('bottles')
gtImages = importDataset('gt')
counter = np.zeros([len(bottlesImages),len(gtImages)])
for i in range(0,len(bottlesImages)):
    image = bottlesImages[i]
    index = image.find('.')
    filename = image[:index] + '.json'
    exists = os.path.isfile(filename)
    if not exists:
        print(filename + 'doesn\'t exists. Run recognition.py first.' )
        break
    else:
        # Get recognition results for image
        with open(filename, 'r') as file:
            jsonBottle = json.load(file)

        wordsBottles = []
        for words in jsonBottle['recognitionResult']['lines']:
            for word in words['words']:
                if word['text'] not in wordsBottles:
                    wordsBottles.append(word['text'])

        # Get recognition results for every image in gt
        # and count matching words with image from bottles
        for j in range(0,len(gtImages)):
            gtImage = gtImages[j]
            index = gtImage.find('.')
            filenameGt = gtImage[:index] + '.json'
            with open(filenameGt, 'r') as file:
                jsonGt = json.load(file)

            wordsGt = []
            for words in jsonGt['recognitionResult']['lines']:
                for word in words['words']:
                    if word['text'] not in wordsGt:
                        wordsGt.append(word['text'])

            for word in wordsBottles:
                if word in wordsGt:
                    counter[i][j] += 1

    print(counter[i])
    matchIndex = np.argmax(counter[i])
    match = gtImages[matchIndex]
    names = match.split('\\')
    match = names[-1]
    index = match.find('.')
    match = match[:index]

    names = image.split('\\')
    folderName = names[-2]
    names = filename.split('\\')
    filename = names[-1]
    print(filename + ' (' + folderName + ')  matches to ' + match)
