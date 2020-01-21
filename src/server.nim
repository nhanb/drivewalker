import asynchttpserver, asyncdispatch, asyncfile, json, options, tables
import gdrive


proc serveRpc(req: Request) {.async.} =
  if req.reqMethod != HttpPost:
    await req.respond(Http400, "This endpoint only suports POST requests.")
    return

  try:
    var bodyJson = parseJson(req.body)
    let rpcMethod = bodyJson["method"].getStr()
    #let rpcParams = bodyJson["params"]

    case rpcMethod
    of "prepare_credentials":
      let credsOption = loadCredentials()
      if credsOption.isSome:
        let headers = newHttpHeaders([("Content-Type", "application/json")])
        await req.respond(Http200, $(%*credsOption.get()), headers)
      else:
        await req.respond(Http500, "Failed to load credentials")

    else:
      await req.respond(Http400, "Invalid RPC method")

  except JsonParsingError:
    await req.respond(Http400, "Malformed RPC request payload")

proc cb(req: Request) {.async.} =
  let path = req.url.path[1..^1]

  const STATIC_FILES = {
    "client.js": "text/javascript",
    "client.css": "text/css",
  }.toTable

  if STATIC_FILES.hasKey(path):
    # TODO: I may want to inline everything into a single html file
    var file = openAsync(path, fmRead)
    let data = await file.readAll()
    file.close()
    let headers = newHttpHeaders([("Content-Type", STATIC_FILES[path])])
    await req.respond(Http200, data, headers)
    return

  case path
  # json-rpc endpoint:
  of "api":
    await serveRpc(req)

  else:
    # Instead of 404, serve default HTML so client-side SPA routing takes over:
    var file = openAsync("client.html", fmRead)
    let data = await file.readAll()
    file.close()
    let headers = newHttpHeaders([("Content-Type", "text/html")])
    await req.respond(Http200, data, headers)


if isMainModule:
  var server = newAsyncHttpServer()
  waitFor server.serve(port = Port(8080), callback = cb, address = "localhost")
