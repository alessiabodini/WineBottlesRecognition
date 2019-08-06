import json
import os
import numpy as np
import matplotlib.pyplot as plt
from util import *
from get_scores import getScores
from recognition import *

# Images' directories
gtDir = 'images_winebottles\\gt\\'
bottlesDir = 'images_winebottles\\bottles\\'
rawDir = 'images_winebottles\\raw\\'

# Import dataset
bottlesImages = importDataset('bottles') # or 'raw'
gtImages = importDataset('gt')

# List of bottles names
bottlesNames = []
for i in range(len(gtImages)):
    bottlesNames.append(extractFileName(gtImages[i], -1))

ranks = np.zeros(len(gtImages))

for i in range(0,len(bottlesImages)):
    image = bottlesImages[i]

    # Create .json file if it doesn't exist
    index = image.find('.')
    filename = image[:index] + '.json'
    exists = os.path.isfile(filename)
    if not exists:
        print(filename + 'doesn\'t exists. Run recognition.py first.' )
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
print('Accurancy: {}'.format(auc))
