import json
import cv2
import os
import time
import tesserocr
from tesserocr import PyTessBaseAPI

def new_recognition(images):

    for image in images:
        # Check is json already exists
        index = image.find('.')
        jsonfile = image[:index] + '_NEW.json'
        exists = os.path.isfile(jsonfile)
        if not exists:
            # Call text_detection.py and return coordinates found in boxes.json
            call = 'python opencv-text-detection\\text_detection.py --image ' + image + ' --east opencv-text-detection\\frozen_east_text_detection.pb'
            os.system(call)

            # Extract coordinates from boxes.json
            startX, startY, endX, endY = [], [], [], []
            boxesfile = image[:index] + '_BOXES.json'
            with open(boxesfile, 'r') as file:
                data = json.load(file)
            for box in data['boxes']:
                startX.append(box['startX'])
                startY.append(box['startY'])
                endX.append(box['endX'])
                endY.append(box['endY'])

            # Find the biggest box
            newStartX = min(startX)
            newStartY = min(startY)
            newEndX = max(endX)
            newEndY = max(endY)

            # Crop image given box
            img = cv2.imread(image)
            crop_img = img[newStartY:newEndY, newStartX:newEndX]
            crop_image = image[:index] + '_CROPPED.jpg'
            cv2.imwrite(crop_image, crop_img)

            # Send box to tesserocr
            #print(tesserocr.tesseract_version())
            #print(tesserocr.get_languages())
            with tesserocr.PyTessBaseAPI(path='C:\\Users\\ale19\\AppData\\Local\\Tesseract-OCR\\tessdata') as api:
                api.SetImageFile(image)
                text = api.GetUTF8Text()

            # Save words found in image_name.json
            words = text.split()
            data = {}
            data['words'] = []
            if not words:
                data['words'].append(' ')
            for word in words:
                data['words'].append(word)
            with open(jsonfile, 'w') as file:
                json.dump(data, file, sort_keys = True, indent = 4)

            # Remove cropped image from folder
            time.sleep(1)
            os.remove(crop_image)

            print('Recogniton ended for {}\n'.format(image))
