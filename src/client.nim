include karax / prelude
include karax / [kajax]
import karax / kdom
import api


proc createDom(): VNode =
  result = buildHtml(tdiv):
    tdiv(id = "main"):
      button:
        text "GET credentials"
        proc onclick(ev: Event; n: VNode) =
          ajaxPost(
            "/api",
            headers = @[],
            data = """
            {
              "jsonrpc": "2.0",
              "method": "prepare_credentials"
            }
            """,
            cont = proc (httpStatus: int; response: cstring) =
            kdom.document.title = "Done"
          )

setRenderer createDom
