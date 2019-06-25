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
        scores = np.zeros(len(gtImages))
        for wordImage in range(len(wordsImage)):
            for wordGt in range(len(wordsGt)):
                scores[i] += damerau_levenshtein_distance(wordImage, wordGt)

    return scores
