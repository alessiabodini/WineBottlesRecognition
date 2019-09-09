from util import importDataset
from recognition import *
from new_recognition import *

# Connect to API for Text-Recognition
images = importDataset('gt')
new_recognition(images)
