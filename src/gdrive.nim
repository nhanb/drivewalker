import json, options, os, httpClient, strutils


type GdriveCredentials* = object
  appId*: string
  appSecret*: string
  refreshToken*: string
  accessToken*: string


proc getAccessToken(
    appId: string, appSecret: string, refreshToken: string
  ): Option[string] =
  let client = newHttpClient()
  client.headers = newHttpHeaders({"Content-Type": "application/json"})
  let body = %*{
      "client_id": appId,
      "client_secret": appSecret,
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
  }
  let response = client.request(
    "https://www.googleapis.com/oauth2/v4/token",
    httpMethod = HttpPost,
    body = $body
  )
  if startsWith(response.status, "200"):
    return some(parseJson(response.body)["access_token"].getStr())
  else:
    echo "Failed to get access token:", response.body
    return none(string)


proc loadCredentials*(filename = "gdrive.json"): Option[GdriveCredentials] =
  if not existsFile(filename):
    echo "File", filename, "doesn't exist!"
    return none(GdriveCredentials)

  var file = open(filename, fmRead)
  let data = file.readAll()
  file.close()

  let creds = parseJson(data)
  let accessToken = getAccessToken(
    creds["appId"].getStr(),
    creds["appSecret"].getStr(),
    creds["refreshToken"].getStr(),
  )
  if accessToken.isSome:
    creds.add("accessToken", %accessToken.get())
    return some(creds.to(GdriveCredentials))
  else:
    return none(GdriveCredentials)


when isMainModule:
  let creds = loadCredentials()
  if creds.isNone:
    echo "oops"
  else:
    echo creds.get()
