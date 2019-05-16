import os

def importDataset(dataset):
    # Images' directories
    gtDir = 'images_winebottles\\gt\\'
    bottlesDir = 'images_winebottles\\bottles\\'

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
        print('Images names loaded.')
        return gtImages

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

    print('Images names loaded.')
    if dataset == 'bottles':
        return bottlesImages
    return gtImages + bottlesImages
