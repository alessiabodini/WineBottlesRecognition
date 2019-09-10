import json
import os
import numpy as np
import matplotlib.pyplot as plt
from util import *
from new_get_scores import getScores
from new_recognition import *

# Images' directories
gtDir = 'images_winebottles\\gt\\'
bottlesDir = 'images_winebottles\\bottles\\'
rawDir = 'images_winebottles\\raw\\'

# Import dataset
dataset = 'raw' # or 'bottles'
bottlesImages = importDataset(dataset)
gtImages = importDataset('gt')

# List of bottles names
bottlesNames = []
for i in range(len(gtImages)):
    bottlesNames.append(extractFileName(gtImages[i], -1))

# Recognition of the chosen dataset
new_recognition(gtImages)
new_recognition(bottlesImages)

ranks = np.zeros(len(gtImages))

for i in range(0,len(bottlesImages)):
    image = bottlesImages[i]
    index = image.find('.')
    filename = image[:index] + '_NEW.json'

    # Open file with results of image
    with open(filename, 'r') as file:
        jsonBottle = json.load(file)
    # Copy all words found
    wordsBottle = []
    for word in jsonBottle['words']:
        if word not in wordsBottle:
            wordsBottle.append(word)

    # Get recognition results for every image in gt
    # and calculate score with image from bottles
    scores = getScores(wordsBottle)

    # Sort scores and corresponding gtImages
    indexSort = np.argsort(scores)
    indexRank = np.argmin(scores)
    bottlesNames = np.asarray(bottlesNames)
    rank = bottlesNames[indexRank]
    sort = bottlesNames[indexSort]

    # Search for correct matches
    folderName = extractFileName(image, -2)
    for idx in range(len(indexSort)):
        if bottlesNames[indexSort[idx]] == folderName:
            ranks[idx] += 1

# Show plot given ranks
x = np.array(range(len(bottlesNames)))
x += 1
plt.plot(x, ranks, 'o')
plt.xlabel('Position')
plt.ylabel('Matches')
#plt.axis([0, len(bottlesNames)+1, -1, len(bottlesImages)])
plt.grid()
plt.title('Matches plot')
plt.show()

# Show plot CMC
ranks = ranks / len(bottlesImages) # calculate frequency instead of the absolute value
cmc = np.cumsum(ranks)
plt.plot(cmc)
plt.title('CMC plot')
plt.show()

# Calculate AUC
auc = np.trapz(cmc, dx=1/len(gtImages))
print('\nAccurancy: {}'.format(auc))

# RESULTS:
# - raw: 0.5288
# - bottles: 0.5981
