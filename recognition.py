import http.client, urllib.request, urllib.parse, urllib.error, base64
import time
import json
import os
from util import importDataset

# Defining HTTP requests
headersPost = {
    # Request headers
    'Content-Type': 'application/octet-stream',
    'Ocp-Apim-Subscription-Key': '6dc622eb5a174066aa5c56e674018b75'
}

headersGet = {
    # Request headers
    'Ocp-Apim-Subscription-Key': '6dc622eb5a174066aa5c56e674018b75'
}

params = urllib.parse.urlencode({
    # Request parameters
    'mode': 'Printed',
})

# Connecting to API for Text-Recognition
images = importDataset('all')
for name in images:
    index = name.find('.')
    filename = name[:index] + '.json'
    exists = os.path.isfile(filename)
    if not exists:
        with open(name, 'rb') as image:
            img = image.read()
            print(name)

            try:
                conn = http.client.HTTPSConnection('westeurope.api.cognitive.microsoft.com')
                conn.request('POST', '/vision/v2.0/recognizeText?%s' % params,
                    img, headersPost)
                response = conn.getresponse()
                print(response.status, response.reason)
                location = response.getheader('Operation-Location')
                #print(location)
                conn.close()

                time.sleep(2)
                conn = http.client.HTTPSConnection('westeurope.api.cognitive.microsoft.com')
                conn.request('GET', location, '', headersGet)
                response = conn.getresponse()
                print(response.status, response.reason)
                data = response.read()
                #print(data)
                conn.close()

                data = json.loads(data.decode('utf8'))
                #print(data)
                with open(filename, 'w') as file:
                    json.dump(data, file, sort_keys = True, indent = 4)

                print()

            except Exception as e:
                print("[Errno {0}] {1}".format(e.errno, e.strerror))

print('All images analyzed.')
