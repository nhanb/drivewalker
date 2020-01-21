include karax / prelude
include karax / [kajax]
import karax / kdom
import api

var chapter = Chapter(
  name: kstring"",
  pages: @[]
)


proc createDom(): VNode =
  result = buildHtml(tdiv):
    button:
      text "GET chapter"
      proc onclick(ev: Event; n: VNode) =
        ajaxPost(
          "/api",
          headers = @[],
          data = """
          {
            "jsonrpc": "2.0",
            "method": "get-chapter",
            "params": {
              "id": "84749"
            }
          }
          """,
          cont = proc (httpStatus: int; response: cstring) =
          chapter = fromJson[Chapter](response)
          kdom.document.title = chapter.name
        )
    for url in chapter.pages:
      tdiv:
        img(src = url)

setRenderer createDom
