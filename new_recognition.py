import json

def recognition(images):
    for image in images:
        # Call text_detection.py and return coordinates found in boxes.json
        os.system("python opencv-text-detection\\text_detection.py --image 'image' --east frozen_east_text_detection.pb")

        # Extract coordinates from boxes.json
        startX, startY, endX, endY = []
        index = name.find('.')
    	filename = "image-boxes\\" + name[:index] + '.json'
        with open(filename, 'w') as file:
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

        # Send box to tesserocr
