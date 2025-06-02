extends Control

func _ready():
  var data = await httpGet("https://api.github.com/repos/rsa17826/vex-plus-plus/releases")
  for release in data:
    var path
    for file in release.assets:
      if file.name == "windows.zip":
        path = file.browser_download_url
        break
    print(release['tag_name'], path)

func httpGet(url):
  var http_request = HTTPRequest.new()
  var promise = Promise.new()
  add_child(http_request)
  http_request.request_completed.connect(func(result, response_code, headers, body):
    var json=JSON.new()
    json.parse(body.get_string_from_utf8())
    var response=json.get_data()
    if response_code == 200:
      promise.resolve(response)
    else:
      promise.reject(response_code)
  )

  var error = http_request.request(url)
  if error != OK:
    push_error("An error occurred in the HTTP request.")
  return await promise.wait()