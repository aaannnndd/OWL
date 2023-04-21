# OPEN WARLORDS

Welcome to the Open Warlords project! This project was written from scratch while taking notes from the vanilla code and warlords Redux. The goal is to provide an improved experience over the base vanilla warlords by solving the most commonly complained about bugs, improving FPS and multiplayer security. Apologies if this repository is still a bit of a mess. it's been just me working on the project and comments/documentation/issues have mainly served as quick post it notes so I don't forget things - it will get cleaned up as time goes on.

There has been a lot of frustration with warlords regarding support for the game mode and ingame moderation. Given the games age, it isn't economically feasible for the game developers to continue support at a level the community demands (Software maintenance is the majority of a projects cost). My hope is that this will be a community supported and run project with its own server and active admins to deal with cheaters/griefers. (This will cut down on needing anti-grief scripts and increase performance as well).

I've purchased a dedicated server for testing and plan to upgrade it once the project is nearly completed and has gone through testing. The server host has a 5GHz+ package which should provide an awesome experience. I'll personally foot the bill for a month or two, but hope the option for crowdsource payment through the server host will hopefully make it a bit more sustainable.

If you would like to see how the project is coming along, the test server is usually running an up to date version of the project.

**Discord**: https://discord.gg/DQjYRMvv

**Server Info**: 160.202.167.19:2542

**Server Name**: [Warlords] Aircraft Practice

The server has a tab for 'free jets' for fun while in development. Press 'U' to open the menu.

# **TECHNICAL CHANGES**

## **SECURITY**:

The code is separated into client and server. Client requests everything from the server, and the server executes the code on their behalf. There are some places it's not feasible, but this will solve 95% of hacking problems. This will make filtering out/disabling commands much easier as the client won't require the use of much functionality over that of an empty mission.

The client and server share the same 'request condition checks'. The client UI will use these checks to enable/disable buttons/components that allow them to send the request (also prevents servers from reciving unneccesary network traffic). If the client is cheating and finds a way around the 'condition check', the server uses the exact same function to check and will deny the request and log it to file.

Majority of variables will be kept in localNamespace on the server and updated on the clients. Depending on what works best, clients may have the same variables stored localNamespace and kept synced. *This will be done after development to simplify things and ensure it's implemented in a way that works with all the features and their edge cases.*

## **PERFORMANCE**:

There is no use of 'triggers'. In vanilla, there is 58 sectors, with 4 triggers each, doing checks every 0.5 seconds to see if units are in range. That's 232 triggers, checking upwards of 200 objects every 0.5 seconds.

There is minimal use of spawned loops for any reason. If they exist they are short lived and always terminate on their own. Running 'diag_activeScripts' in vanilla has over 200+ spawned scripts at the start and increases as more and more sectors are unlocked. It's currently down to 2 (4 with revive enabled).

The server inits variables and game state, then spawns a single game loop which handles sector seizing calculations + command point/minute payouts. After init the server runs 0 code except a check every 1 second for handling sector seizing (things related to unit position checks) and updates clients when neccessary. It then waits for requests from the client and processes those as they come in.

The "unit position checks" take advantage of the fact that you can check the sectors most likely to contain units first, removing those units from the list as they are found (Can only be in one sector at a time). This means if you have a full server (50 players with 5 AI each), you very likely don't have to check all 250 units against all 58 sector positions. By checking main bases + contested + airfields first, you'll likely find 90% of the units 10 sectors in. This comes with the added benefit of being able to do the checks for; zone restriction, sector seizing, sector in combat, all in one fell swoop.

The performance gains are already noticable in an empty server, but will become exponentially noticable as the playercount increases.
&nbsp;
## **Program Flow:**

    quick reference
    
    init.sqf
        initCommon.sqf
            clientRequestConditions.sqf
            commonFunctions.sqf
        initServer.sqf
            serverFunctions.sqf
            clientRequests.sqf
            initSectors.sqf
            serverEventHandlers.sqf
            *spawn Main game loop*
                handleIncomePayout.sqf
                sectorAreaCheck.sqf
                    handleSectorSeizing.sqf
        initClient.sqf
           serverResponse.sqf
           initGUI.sqf
               initGUIFunctions.sqf
               initMenu.sqf
           clientEventHandlers.sqf
           initPlayerTracking.sqf
        
    All remaining functions on the client are called through the UI, or via remoteExec notifications from the server.
    All remaining functions on the server are called in response to client requests, or due to conditions in the main game loop.

*A focus has been placed on getting code working, with the optimization coming later. Much of the code is written with a lot of extra variables or potentially unneccessary functions for the sake of clarity while the project is in development*

### **Server**
1. Initialize common functions and variables
2. Initialize server default values and static variables/functions
3. Initialize sectors
4. Initialize event handlers
5. Spawn a game state loop for sector area checks + income updates
6. Notify clients as sectors are captured/seized + Process requests from clients

### **Client**

1. Initialize common function and variables
2. Initialize client default values and static variables/functions
3. Sent request to be initialized to the server
4. Await "OK"
5. Initialize client with any extra data the server sends back
6. Initialize the UI
7. Wait for player to interact with UI to request things from server

### **Client-server interaction**
  - **Server\clientRequests.sqf** -> function remote executed by the client on the server
  - **Client\serverResponse.sqf** -> functions remote executed by the server on the client
  - **Common\clientRequestConditions.sqf** conditions checked by;
    - The client before sending a client request (determines UI component state)
    - The server before executing the request and sending back a response
\
&nbsp;
# **PROJECT GOALS**

## **GAMEPLAY**
- **Intuitive for new players**
  - Tutorials / FAQ
  - Make important information readily available through the UI.
  - Add explanatory tooltips as much as possible
  - Auto-show important UI components (GPS, NVG)
  - Default Loadouts (Arsenal is an overload of unsorted guns)
  - Custom weapon selection UI with better categorization + scope preview 
- **Make the early game more fun/interesting/strategic**
  - Engaging scavenging system to unlock loadouts
  - Encourage use of transport vehicles / helicopters + have it contribute useful resources to a team (increase tickets, ect).
  - Make room for medic revive gameplay & have it contribute more than a force respawn.
  - Bonuses for not dying
- **Improve the infantry experience with and without AI**
  - Decrease spawn camping (replace the need to spawn camp with a ticket system?)
  - Ability to purchase more squad mates
  - Ability to upgrade AI skill potentially
  - Force enter (teleport) AI into vehicles
  - Control over 'allowCrewInImmobile' for player owned vehicles
  - Subtle/sneaky 'setAnimSpeedCoeff 1.15'?
  - Options to disable command view / thermals
- **Increase overall strategy**
  - *Manual control over choosing types of units that spawn when a player controlled sector is attacked.*
  - *Ability to re-enable zone restrictions to prevent back capping
  - Add additional bonuses to a sectors strategic importance (datalink, negative command points)*
  - *Ability to spawn aircraft midair when a sector is lost if no air assets are owned by the team.*
  - *Smoke artillery *maybe**
  - *Aircraft carrier *maybe**

&nbsp;
## **PERFORMANCE**
- **Using 'spawn + sleep' only when neccessary.**
- **Saving script handles from spawn, and terminating them or checking one doesn't already exist/duplicate.**
- **Notifying the client/server when different events happen, instead of having them check with a loop.**
- **Server has a ton of RAM, don't be afraid to use it to gain performance elsewhere (client or server).**
- **Avoid unneccesary network traffic. If nothing has changed don't send an update.**
- **Use remoteExec to individual clients / specific sides.**
- **Avoid the use of arma's 'triggers' at all costs.**
- **Clever garbage collection whenever possible**
\
&nbsp;
# **INGAME CHANGES**

Many of these are tenative on testing and will be added as optional features via server params. The idea is to have a base game that is nearly identical in terms of gameplay to vanilla, with options to improve it. Many of the below changes (Loadouts for example) do not change gameplay at all, and are a QoL change for new players to be useful vs vehicle threats.

## **Sectors**
- Fast travelling to a friendly sector will always place you behind cover (inside a building in most cases).
- Fast travelling to contested changes.
- Full control over the conditions for sector capping. Currently both teams can sway the cap in both directions - no 'cap interrupts' via cheesy means.
- Sectors have a 'fast travel' ticket system. Exhausting an attackers/defenders fast travel tickets will ensure that an assault on a base has an 'end'.
- Sectors can be re-inforced by purchasing assets for them once the sector is seized. These will spawn when the enemy team attacks the base.
- Sectors can regain a 'zone restriction' (cannot be back capped) if a team fully re-inforces a sector. (Sector must only have friendly adjacent sectors).
- *Sectors have new 'perks' - 'transport helipads' to allow transport helis earlier in the game. 'radio tower' to enable datalink for vehicles* (WIP)
- *Contributing towards a sector capture will give command points to players* (WIP)

## **Loadouts**
- Medic loadout - can revive and fully heal other players
- Engineer loadout - can repair vehicles and disarm mines
- Squad leader loadout - free
- Arsenal - still exists
- Anti-Tank loadout - MAWWS to keep it reasonable
- Anti-Air loadout - The more the merrier
- All loadouts unlocked via scavenging/putting AT/AA/MediKits/Toolkit gear into the ammocache at main base.
- Scavenging will be made easier via early game transport heli availability


## **Miscellaneous**
- Slammer doesn't weight as much (Can climb hills faster than walking speed)
- Large FPS improvements
- Ability to play as AAF functional with additional config entries. *I think they are still too weak as a faction, probably better off adding AAF assets to blufor*
- Support for Aircraft Carrier added *Map texture draws over everything else - doesn't look polished enough for my liking - doubt it will be added*
- Option for disabling 'command view'.
\
&nbsp;

## **UI CHANGES**

Created a new tabbed menu UI to allow for room for different categories of functionality and give a general facelift over the old one. Still a work in progress - I'm no graphic designer but the potential is there.

\
**Options Menu**
- Hide chat of muted players
- Disable zome-restriction sounds (air raid siren)
- Auto-enable NVG at nighttime on respawn
- Hide ambient life (Seagull or Xian? No more!)
- Hide vote kick messages
- Hide connection/system messages
- **Hide location from team - prevent spies* (maybe)

\
**Strategy Menu**
- Ability to buy assets for a sector (Will spawn when attacked next) available asset slots = [Infantry, LAV, Armor]
- Ability to choose cheap default loadouts (Medic, Engineer, Squad Leader, Anti-Tank, Anti-Air)
  - Medic can revive, Engineer can repair/disarm mines.
- Fast travel
- Sector Scan + Cooldown indicator
- Sector Voting

\
**Asset Menu**
- Currently really ugly, but functionality is there.
- Multiple 'Gear' crates will be merged into a single one with 'n' times the items. 
- Ability to airdrop vehicles with infantry inside (Avoiding irritation of getting them inside)
- Still all the same functionality to vanilla/redux.

\
**Asset Management Menu**
- List of all owned assets
- Lock/Unlock
- Engine on/off
- Lights on/off
- Radar on/off
- Kick non-squad members from your vehicle
- Clear vehicle inventory
- Delete vehicle
- **Re-arm squad members if inside non-contesed main base (for a price)* (maybe)

\
**Main Map**
- Added fast travel to main map
- Added sector voting to main map
- Added sector scan to main map
\
&nbsp;

# PROGRESS

- Sector Seizing
- Zone restrictions
- Airdrop
- Defense deployment
- Aircraft Arrival
- Naval deployment
- Sector voting
- Sector seizing
- Fast Travel
- Sector Scan
- UI functionality of all core vanilla features
- AI sector defense spawning