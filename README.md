# OpenWarlords

## Features over Vanilla

### New Menu

**Options Menu**
- Hide chat of muted players
- Disable zome-restriction sounds (air raid siren)
- Auto-enable NVG at nighttime on respawn
- Hide ambient life (Seagull or Xian? No more!)
- Hide vote kick messages
- Hide connection/system messages
- *POTENTIALLY (Hide location from team - prevent spies?)

**Strategy Menu**
- Ability to buy assets for a sector (Will spawn when attacked next) available asset slots = [Infantry, LAV, Armor]
- Ability to choose cheap default loadouts (Medic, Engineer, Squad Leader, Anti-Tank, Anti-Air) - Medic can revive, Engineer can repair/disarm mines.
- Fast travel
- Sector Scan + Cooldown indicator
- Sector Voting

**Asset Menu**
- Multiple 'Gear' crates will be merged into a single one with 'n' times the items. 
- Ability to airdrop vehicles with infantry inside (Avoiding irritation of getting them inside)

**Asset Management Menu**
- List of all owned assets
- Lock/Unlock
- Engine on/off
- Lights on/off
- Radar on/off
- Kick non-squad members from your vehicle
- Clear vehicle inventory
- Delete vehicle
- *Potentially re-arm squad members if inside non-contesed main base (for a price)

**Main Map**
- Added fast travel to main map
- Added sector voting to main map
- Added sector scan to main map

### Gameplay Improvements

**Sectors**
- Fast travelling to a friendly sector will always place you behind cover (inside a building in most cases).
- Fast travelling to contested changes.
  - Teammates close to the AO will server as spawn points for the team.
  - A teammate can only be a spawn point, if their last fast travel location was a friendly sector.
- Full control over the conditions for sector capping. Currently both teams can sway the cap in both directions - no 'cap interrupts' via cheesy means.
- Sectors have a 'fast travel' ticket system. Exhausting an attackers/defenders fast travel tickets will ensure that an assault on a base has an 'end'.
- Sectors can be re-inforced by purchasing assets for them once the sector is seized. These will spawn when the enemy team attacks the base.
- Sectors can regain a 'zone restriction' (cannot be back capped) if a team full re-inforces a sector. (Sector must only have friendly adjacent sectors).
- *Sectors have new 'perks' - 'transport helipads' to allow transport helis earlier in the game. 'radio tower' to enable datalink for vehicles* (WIP)
- *Contributing towards a sector capture will give command points to players* (WIP)

**Loadouts**
- Medic loadout - can revive and fully heal other players
- Engineer loadout - can repair vehicles and disarm mines
- Squad leader loadout - free
- Arsenal - still exists
- Anti-Tank loadout - MAWWS to keep it reasonable
- Anti-Air loadout - The more the merrier
- All loadouts unlocked via scavenging/putting AT/AA/MediKits/Toolkit gear into the ammocache at main base.
- Scavenging will be made easier via early game transport heli availability

**Miscellaneous**
- Slammer doesn't weight as much (Can climb hills faster than walking speed)
- Large FPS improvements (Went from 200+ active scripts and 200 triggers, to 2 active scripts and 0 triggers on the client)
- Ability to play as AAF functional with additional config entries. *I think they are still too weak, probably better off adding AAF assets to blufor*
- Support for Aircraft Carrier added *Map texture draws over everything else - doesn't look polished enough for my liking - doubt it will be added*
- Option for disabling 'command view'.

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
