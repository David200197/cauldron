<link
  rel="stylesheet"
  href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"
/>

# Running an adventure
Right clicking with the mouse on a character, a token or the map opens a menu with options. Most options should explain themselves enough, but here is some information to make your understanding of Cauldron easier and faster.

<i class="fa-solid fa-warning"></i> Create effect: An effect is a temporary visual marker on the map. When de Dungeon Master reloads the map, they are gone.

<i class="fa-solid fa-lightbulb"></i> Create light: A light only has effect on a map with Fog of War type set to night / dark.

<i class="fa-solid fa-hand"></i> Hand over: Give control over this object to the player of the character which as your focus (double-click a character token). That player is now able to move and rotate that object.

<i class="fa-solid fa-hand-back-fist"></i> Take back: Take back the control over this object from all other players.

<i class="fa-solid fa-shield"></i> Attack: This rolls a D20 dice. The attack bonus you enter is added to the result of the dice roll. Only the outcome of the roll is shared with the players.

<i class="fa-solid fa-compass"></i> Send to map: Makes the character invisible and sends it to another map. That map will also open in the Dungeon Master's browser.

You can focus on a token or a player character by double clicking it. This allows you to control it via the keyboard. Double-clicking a token or player character while holding the CTRL button toggles its presence. Double-clicking a light toggles it on and off.

## Combat
A battle is started by clicking the Combat button in the menu window or by entering /combat in the command line field. It rolls initiative for all players using their initiative bonus. You can add monsters or monster groups by entering their name and optionally their initiative bonus.


When the combat has started, additional buttons appear above the command line field. The following buttons are available:

- **>** : Makes it the next character's or monster's turn.
- **+** : An input field will appear. Enter the name of a monster that has to be added to the combat. It will be that monster's turn.
- **-** : A clickable Combat Tracker list will appear. Click the name of the character or monster that has to be removed from the combat.
- **×** : Stops the combat.
You can also add monsters via the /add command and remove them via the /remove command. Change the player's turn via the /next command and, optionally, provide a name (or the first part of its name as long as it's unique) to change the battle order. Use the /done command to stop the battle.

![menubar](./combat_buttons.png)

## Drawing on the map
As a Dungeon Master, you can make drawings on the screen. Hold the CTRL key to draw and the SHIFT key to erase. Open de menu in the upper right corner for all available drawing colors. Press the CTRL key while erasing to erase a larger area. Pressing the ALT key aligns the drawing or erasing to the grid.

The Fog of War 'manually reveal' mode is in fact nothing but a map covered with black paint, which is made half transparent for the Dungeon Master. Reveal the map like you would remove map paint, using SHIFT for small parts or CTRL+SHIFT for larger parts.

- Go to [Manual](../README.md)