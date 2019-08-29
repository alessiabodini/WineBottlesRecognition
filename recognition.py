import http.client, urllib.request, urllib.parse, urllib.error, base64
import time
import json
import os
from util import extractFileName

# Define HTTP requests
headersPost = {
    # Request headers
    'Content-Type': 'application/octet-stream',
    'Ocp-Apim-Subscription-Key': '54a6da0974cd4f0994a4011a965d3790'
}

headersGet = {
    # Request headers
    'Ocp-Apim-Subscription-Key': '54a6da0974cd4f0994a4011a965d3790'
}

params = urllib.parse.urlencode({
    # Request parameters
    'mode': 'Printed',
})

def recognition(images):
    # Connect to API for Text-Recognition
    for name in images:
        index = name.find('.')
        filename = name[:index] + '.json'
        exists = os.path.isfile(filename)
        if not exists:
            with open(name, 'rb') as image:
                img = image.read()
                print(name)

                try:
                    conn = http.client.HTTPSConnection('westcentralus.api.cognitive.microsoft.com')
                    conn.request('POST', '/vision/v2.0/recognizeText?%s' % params,
                        img, headersPost)
                    response = conn.getresponse()
                    print(response.status, response.reason)
                    location = response.getheader('Operation-Location')
                    #print(location)
                    conn.close()

                    time.sleep(3)
                    conn = http.client.HTTPSConnection('westcentralus.api.cognitive.microsoft.com')
                    conn.request('GET', location, '', headersGet)
                    response = conn.getresponse()
                    print(response.status, response.reason)
                    if response.status >= 400 and response.status < 500:
                        print('Something went wrong, try again.')
                        conn.close()
                        return response.status
                    data = response.read()
                    #print(data)
                    conn.close()

                    data = json.loads(data.decode('utf8'))
                    #print(data)
                    with open(filename, 'w') as file:
                        json.dump(data, file, sort_keys = True, indent = 4)
                    #return 1

                except Exception as e:
                    print("[Errno {0}] {1}".format(e.errno, e.strerror))

            print('Recognition ended for {}.'.format(extractFileName(name, -1)))
            print()
