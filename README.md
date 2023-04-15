# OpenWarlords

## Program Flow:

### Server

- 1). Initialize common functions and variables
- 2). Initialize server default values and static variables/functions
- 3). Initialize sectors
- 4). Initialize event handlers
- 5). Spawn two loops, 1 for sector area checks, 2 for income updates
- 6). Notify clients as sectors are captured/seized + Process requests from clients


### Client

- 1). Initialize common function and variables
- 2). Initialize client default values and static variables/functions
- 3). Sent request to be initialized to the server
- 4). Await "OK"
- 5). Initialize client with any extra data the server sends back
- 6). Initialize the UI
- 7). Wait for player to interact with UI to request things from server

## Goals

### Performance
- Using 'spawn + sleep' only when neccessary. (mainly UI)
- Saving script handles from spawn, and terminating them or checking one doesn't already exist/duplicate.
- Notifying the client/server when different events happen, instead of having them check with a loop
- Server has a ton of RAM, don't be afraid to use it to gain performance elsewhere (client or server).
- Avoid unneccesary network traffic. If nothing changed don't send an update.
- Use remoteExec to individual clients / specific sides.
- Avoid the use of arma's 'triggers' at all costs.

### Gameplay
- Intuitive for new players. This will mostly be done through UI
- Make the early game more fun/interesting/strategic
- Encourage the use of transport helicopters
- Improve the infantry experience with AI
- Add more strategy overall
