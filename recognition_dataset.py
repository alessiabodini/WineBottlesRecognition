from util import importDataset
from recognition import *

# Connect to API for Text-Recognition
images = importDataset('all')
recognition(images)
