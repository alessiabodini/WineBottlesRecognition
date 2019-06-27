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
    scores = np.ones((len(gtImages), len(wordsImage)))
    final = np.zeros(len(gtImages))
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

        for j in range(len(wordsImage)):
            for wordGt in wordsGt:
                new = normalized_damerau_levenshtein_distance(wordsImage[j], wordGt)
                if new < scores[i][j]:
                    scores[i][j] = new
            final[i] += scores[i][j]

    return final
