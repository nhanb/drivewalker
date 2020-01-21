all: server client.js

client.js: src/client.nim
	nim js -o:client.js src/client.nim

server: src/server.nim
	nim c -d:ssl -o:server src/server.nim

deps: readman.nimble
	nimble install -d

clean:
	rm -f client.js server
