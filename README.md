

# PactSafe iOS Snippet Demo

## Setup
1. Add your PactSafe site access_id to the clickwrap.html
2. Create and publish a group, then add its group_key to the clickwrap.html
3. Publish the page and add the URL to ViewController.swift

## Awesome Local Setup
1. `npm install http-server -g`
2. [download ngrok](https://ngrok.com/download)
3. `http-server .`
4. `ngrok http 8080`
5. Add https url to ViewController.swift (i.e. https://d4077554.ngrok.io/clickwrap.html)
