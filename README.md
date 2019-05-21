# WineBottlesRecognition

###### How to add new images to the dataset?

Inside *images_winebottles*:

- add the _ground-truth image_ of your bottle of wine (if not already present) in the directory *gt*
- add all the other images in the directory *raw* and inside another directory named as the bottle to recognize

###### How to recognize a chosen bottle?

- Run *recognition.py*:
  'python recognition.py'

- Look for the results (in the same directory of the image) in the *image_name*.json file. The first result is the name of the bottle. 

###### How accurate is the result?

Run *validation.py* to find out:
'python validation.py'
