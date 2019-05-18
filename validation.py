import json
import os
import numpy as np
import matplotlib.pyplot as plt
from util import importDataset
from util import extractFileName

# Images' directories
gtDir = 'images_winebottles\\gt\\'
bottlesDir = 'images_winebottles\\bottles\\'

# Import dataset
bottlesImages = importDataset('bottles')
gtImages = importDataset('gt')

# List of bottles names
bottlesNames = []
for i in range(0, len(gtImages)):
    bottlesNames.append(extractFileName(gtImages[i], -1))

# Creat array with score for every gtImage
scores = np.zeros([len(bottlesImages),len(gtImages)])
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
            # Open file with results of gtImage
            with open(filenameGt, 'r') as file:
                jsonGt = json.load(file)
            # Copy all words found
            wordsGt = []
            for words in jsonGt['recognitionResult']['lines']:
                for word in words['words']:
                    if word['text'] not in wordsGt:
                        wordsGt.append(word['text'])

            for word in wordsBottles:
                if word in wordsGt:
                    scores[i][j] += 1

    # Sort scores and corresponding gtImages
    list = [None] * len(gtImages)
    indexes = np.argsort(-(scores[i])) # negate array to have descending order
    #matches = gtImages[indexes] # error
    j = 0
    for i in indexes:
        match = bottlesNames[i]
        list[j] = match
        j += 1

    # Save gtImages sorted for score
    index = filename.find('.')
    filename = filename[:index]
    filename = filename + '_results.json'
    with open(filename, 'w') as file:
        results = json.dump(list, file, indent = 4)
    print(filename + ' ready.')

    # Search for perfect match
    folderName = extractFileName(image, -2)
    firstMatch = indexes[0]
    nameFirstMatch = bottlesNames[firstMatch]
    if folderName == nameFirstMatch:
        ranks[firstMatch] += 1

#print(ranks)

# Create plot given ranks
plt.plot(bottlesNames, ranks, 'o')
plt.xlabel('Bottles names')
plt.ylabel('Number of match')
plt.axis([-1, len(bottlesNames), 0, 8])
plt.title('Matches plot')
plt.show()

# Show plot CMC
cmc = np.cumsum(ranks)
plt.plot(cmc)
plt.title('CMC plot')
plt.show()

# Calculate AUC
auc = np.trapz(cmc)
print('Accurancy: {}'.format(auc))
