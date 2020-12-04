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

## How does it look in hammer
Download both [dialog_state](vscript/) and [dialog_info](vscript/), put them in vscript/dialog and open [dialog_test](example-map) in hammer.
The general location inside *Counter-Strike Global Offensive\csgo\scripts\vscripts* doesn't matter as long as you update the references inside the script accordingly.

[Example map in the workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2232289356)\
[Official Squirrel Documentation](http://squirrel-lang.org/squirreldoc/reference/index.html)\
[Alternative Squirrel Documentation](https://developer.electricimp.com/squirrel) (more examples and explanation)\
[VDC](https://developer.valvesoftware.com/wiki/List_of_Counter-Strike:_Global_Offensive_Script_Functions)

## Usage
### Creating a dialog
The basic layout of a dialog is a tree structure with a root node to start at and branches of other nodes to folow.
In code this is realized with a single array containing multiple tables, connected through the index of the table in the array.
The last entry of the dialog array is reserved for the current starting node.

#### Difference between player and conversant nodes
The dialog follows the following scheme:
1. The conversant's text gets displayed and the corresponding sound gets played
2. The player can then choose between a set of answers/reaktions/questions or leave the conversation
3. The conversant's text gets displayed and the corresponding sound gets played

Converant nodes are used to play soundfiles, display corresponding text and options, while player nodes are used to store options text and connect conversant nodes.
The layout of the nodes is the same, but some properties are used differently or not at all.

#### Basic Layout
```Squirrel
testDialog <-
[
 {
 topLine = ["Hello there", ...,""],
 sndPath = ["custom/sndfile.wav", ...,""],
 sndDur = [3.0, 2],
 next = [1,2,3,12],
 newEntranceNode = 0,
 nodeFunction = 0
 },
 ...
 },
 0
]

dialogs <- [testDialog]
 ```
##### General
The entries in `topLine`, `sndPath` and `sndDur` are connected and will be processed index by index, which means the arrays should be the same length.\
E.g: The text in `topLine[0]` will be displayed and the soundfile in `sndPath[0]` will be played for as long as `sndDur[0]` specifies.

##### `topLine`
###### Conversant:
Containes all of the text (string) to be displayed in this node.\
`topLine = [""]` means there is only one piece of text, that will be displayed at once.\
`topLine = ["","",...]` means there are multiple entries, that will be displayed one after another, with the last entry staying on screen.

###### Player:
Containes the text (string) to be displayed in a set of options to choose from.

##### `sndPath`
###### Conversant:
Containes all the soundfiles (string, .wav filepath) used in this node.\
`sndPath = [""]` means there is only one soundfile to be played.\
`sndPath = ["",...]` means there are multiple soundfiles to be played, one after another.
###### Player:
Not used.

##### `sndDur`
###### Conversant:
Containes the duration of the soundfiles in seconds (integer/float) in the corresponding `sndPath` index.
###### Player:
Not used.

##### `next`
##### Conversant:
Containes the indexes (integer) of the connected nodes, which will be displayed to the player to choose from. First entry is the top option and last is the bottom one.
###### Player:
Containes the index of the node to be played when choosing this option.

##### `newEntranceNode`
Is used for saving progress upon ending a dialog. Specifies the new starting node to enter the dialog.

##### `nodeFunction`
Used to call a predefined function upon entering a node. Usefull for events tied to dialog (lightchange, screenshake etc).

### Including the dialog
Simply add your array/dialog to `dialogs`
### Starting the dialog
Assuming you set up your entities according to the example map, call `StartDialog(dialogIndex)` with the index of your dialog.
