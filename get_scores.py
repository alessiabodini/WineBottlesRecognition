import json
import os
import numpy as np
from util import *
from recognition import *
from pyxdameraulevenshtein import *

# Images' directory
gtDir = 'images_winebottles\\gt\\'

# Creat array with score for every gtImage
#scores = np.zeros([len(bottlesImages),len(gtImages)])
#ranks = np.zeros(len(gtImages))

def getScores(wordsImage):
    # Get recognition results for every image in gt
    # e relative score with given image
    gtImages = importDataset('gt')
    recognition(gtImages)
    distance = np.zeros(len(wordsImage))
    for i in range(len(gtImages)):
        gtImage = gtImages[i]
        index = gtImage.find('.')
        filenameGt = gtImage[:index] + '.json'
        # Open file with results of gtImage
        with open(filenameGt, 'r') as file:
            jsonGt = json.load(file)
        # Copy all words found
        wordsGt = []
        for words in jsonGt['recognitionResult']['lines']:
            for word in words['words']:
                if word['text'] not in wordsGt:
                    wordsGt.append(word['text'])

        print(wordsGt)
        wordsGt = np.array(['CAPARZO', 'MONTALCINO'])
        for j in range(len(wordsImage)):
            print(wordsImage[j])
            print(wordsGt)
            distance[j] = damerau_levenshtein_distance_ndarray('caparzo', wordsGt)
        scores[i] = sum(distance)

    return scores
