import os
import json
from numpy import *

def importDataset(dataset):
    # Images' directories
    gtDir = 'images_winebottles\\gt\\'
    bottlesDir = 'images_winebottles\\bottles\\'
    rawDir = 'images_winebottles\\raw\\'

    # Importing gt dataset
    gtImages = []
    folderNames = []
    for root, dirs, files in os.walk(gtDir):
        for name in files:
            if (name.endswith('.png') or name.endswith('.jpg')) and root == gtDir:
                index = name.find('.')
                folderName = name[:index]
                folderNames.append(folderName)
                name = os.path.join(root, name)
                gtImages.append(name)
    #print(len(gtImages))

    if dataset == 'gt':
        #print('Images names loaded.')
        return gtImages

    if 'bottles' in dataset or 'all' in dataset:
        # Importing bottles dataset
        bottlesImages = []
        for root, dirs, files in os.walk(bottlesDir):
            for name in files:
                for folderName in folderNames:
                    found = root.find(folderName)
                    if found > 0:
                        break
                if (name.endswith('.png') or name.endswith('.jpg')) and found > 0:
                    name = os.path.join(root, name)
                    bottlesImages.append(name)
        #print(len(bottlesImages))
        #print('Images names loaded.')
        if dataset == 'bottles':
            return bottlesImages
        elif dataset == 'bottles+gt':
            return gtImages + bottlesImages

    if 'raw' in dataset or 'all' in dataset:
        # Importing raw dataset
        rawImages = []
        for root, dirs, files in os.walk(rawDir):
            for name in files:
                for folderName in folderNames:
                    found = root.find(folderName)
                    if found > 0:
                        break
                if (name.endswith('.png') or name.endswith('.jpg')) and found > 0:
                    name = os.path.join(root, name)
                    rawImages.append(name)
        #print(len(rawImages))
        #print('Images names loaded.')
        if dataset == 'raw':
            return rawImages
        elif dataset == 'raw+gt':
            return gtImages + rawImages

    return gtImages + bottlesImages + rawImages


# Extract name from a path (part is the position from the end (negative))
def extractFileName(path, part):
    parts = path.split('\\')
    name = parts[part]
    if part == -1:
        index = name.find('.')
        return name[:index]
    return name


# Import information about bottles: not used
def importBottles():
    with open('bottles.json', 'r') as file:
        bottles = json.load(file)

    wordsInBottles = []
    for bottle in bottles['bottles']:
        words = []
        words.append(bottle['name'])
        for word in bottle['words']:
            words.append(word)
        wordsInBottles.append(words)

    #print(wordsInBottles)
    return wordsInBottles
