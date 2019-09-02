# WineBottlesRecognition

## How to add new images to the dataset?

Inside *__images_winebottles__*:

- add the _ground-truth image_ of your bottle of wine (if not already present) in the directory *__gt__*
- add all the _other images_ in the directory *__raw__* and inside another directory named as the bottle to recognize

## How to recognize a chosen bottle?

- Add the image to recognize in the *__test__* directory

- Run __main.py__:
  - `python main.py`
  
- When asked type in the new image name (extension included)

- The program will return the name of the bottle in your image 

## How accurate is the result?

- Run __validation.py__ to find out:
  - `python validation.py`
 
- The accurancy value is printed at the end
