# vscript-dialog-system
This is an attempt at creating a voiced RPG-like dialog system with branching dialog trees for CS:GO.
Currently only targeted at singleplayer maps, support for coop/multiplayer may be implemented later.

## What does it (already) do
  * Allows for an unlimited amount of dialogs
  * Voicelines for the conversant can be added (optional)
  * Audio and text can be delivered bit by bit (separate Strings and .wav necessary) or all at once
  * Leaving a dialog saves the progress until entered again
  
## How does it work
It makes use of a game_ui entity to map the playercontrols to an env_hudhint. 
All dialog data is stored in a separate file and put together everytime the player makes an input and therefore basically creating a new frame of the menu.
Everything was done using as little vscript as possible so only a basic understanding should be necessary to use this.

[Example map in the workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2232289356)\
[Official Squirrel Documentation](https://developer.electricimp.com/squirrel)\
[Alternative Squirrel Documentation](http://squirrel-lang.org/squirreldoc/reference/index.html) (more examples and explanation)\
[VDC](https://developer.valvesoftware.com/wiki/List_of_Counter-Strike:_Global_Offensive_Script_Functions)
