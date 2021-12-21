import asyncdispatch, asyncnet, os, threadpool
import std/strformat
import protocol

proc connect(socket: AsyncSocket, serverAddr: string) {.async.} =
  echo "Connecting to ", serverAddr
  await socket.connect(serverAddr, 7687.Port)
  echo "Connected!"

  while true:
    let line = await socket.recvLine()
    let parsed = parseMessage(line)
    echo parsed.username, " said: ", parsed.message

echo "Chat application started"

if paramCount() != 2:
  quit(&"Please specify the server address and username, e.g. {getAppFilename()}  localhost ric")

var socket = newAsyncSocket()
let serverAddr = paramStr(1)
let username = paramStr(2)
asyncCheck connect(socket, serverAddr)

var messageFlowVar = spawn stdin.readLine()

while true:
  if messageFlowVar.isReady():
    let message = createMessage(username, ^messageFlowVar)
    asyncCheck socket.send(message)
    messageFlowVar = spawn stdin.readLine()

  asyncdispatch.poll()
