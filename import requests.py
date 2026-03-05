import base64
import requests
import json

# client_id = "CLIENT_ID"
# client_secret = "CLIENT_SECRET"

url = "https://itunes.apple.com/search?term=jack+johnson"

response = requests.get(url)
data = json.loads(response.content)

print(data)