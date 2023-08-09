/*
Handles the progress between nodes in the dialog tree and the construction of the dialog window. Saves the progress upon leaving the dialog.
*/

IncludeScript("dialog/dialog_info");

//Selection highlighting charakters
const SELECTION_MARKER_START = "> ";
const SELECTION_MARKER_END = " <";

//Control flow
generator <- null
//availiable dialogs, active dialog, index in dialogs array
dialogs <- [testDialog];
dialogIndex <- null;
currentDialog <- null;

//Current dialog info
startNodeIndex <- 0;
currentNodeIndex <- null;
topLine <- [];
options <- [];
sndPath <- [];
sndDur <- [];

dialogString <- "";// Must not exceed 510 chars if used with env_hudhint, otherwise will cut off portions of the string
//Entities
gameText <- null;
sound <- null;
gameUI <- null;
timer <- null;
hudHint <- null;

//User input
player <- null;
selection <- 0;
playerControl <- false;

//Debug mode, enables more detailed console output
devmode <- false;

//Print debug messages in console if enabled
function DebugPrint(message){
    if(devmode == true){
        printl(message)
    }
}

//Finds the local player
function GetPlayer()
{
    player = Entities.FindByClassname(null, "player")
    DebugPrint("GetPlayer: " + player)
}

//Not actually used yet, planning on moving as much as possible out of hammer into vscript
function OnPostSpawn() {

    //Setup game_ui entity for dialog control
    gameUI = Entities.CreateByClassname("game_ui")
    gameUI.__KeyValueFromInt("spawnflags", 224)
    gameUI.ValidateScriptScope()
    local scope = gameUI.GetScriptScope()
    scope.AddSelectionRef <- AddSelection
    scope.SubstractSelectionRef <- SubstractSelection
    scope.AcceptOptionRef <- AcceptOption
    gameUI.ConnectOutput("PressedForward", "AddSelectionRef")
    gameUI.ConnectOutput("PressedBack", "SubstractSelectionRef")
    gameUI.ConnectOutput("PressedAttack", "AcceptOptionRef")

    //Setup ambient_generic for voicelines
    sound = Entities.CreateByClassname("ambient_generic")
    sound.__KeyValueFromInt("Volume", 10)
    sound.__KeyValueFromInt("spawnflags", 33)
    sound.ValidateScriptScope()
    local scope = sound.GetScriptScope()

    //Setup timer to recall hudhint
    timer = Entities.CreateByClassname("logic_timer")
    timer.__KeyValueFromInt("RefireTime", 4)
    timer.__KeyValueFromInt("StartDisabled", 1)
    sound.ValidateScriptScope()
    local scope = timer.GetScriptScope()
    //scope.RefreshDialogRef <- RefreshDialog

    //Setup env_hudhint for dialog display
    hudHint = Entities.CreateByClassname("env_hudhint")

}

//Display hud_hint
function ShowDialog(){
    EntFire("HudHint", "ShowHudHint", "", 0, player)
}

//Hide hud_hint
function HideDialog(){
    EntFire("HudHint", "HideHudHint", "", 0, player)
}

//Get next node in dialog tree
function SetCurrentNode(index) {
    if (currentNodeIndex == null){
        DebugPrint("SetCurrentNode: Starting Node: " + startNodeIndex)
        currentNodeIndex = startNodeIndex;//Sets current node to 0; start of dialog
    }else{
        local tempIndex = currentDialog[currentNodeIndex].next[index]//Sets tempIndex to content of index of nextNodes[]
        local newIndex = currentDialog[tempIndex].next[0]
        DebugPrint("SetCurrentNode: Old Node: " + currentNodeIndex + " -> new Node: " + newIndex)
        currentNodeIndex = newIndex;
    }
}

//Filter array by argument and pass to new array; Included in newer versions of Squirrel
function ArrayFilter(array, argument){
    local filteredArray = []
    for(local i = array.len() - 1; i >= 0; i--){
        if(array[i] != argument){
            filteredArray.insert(0, array[i])
        }
    }
    return filteredArray
}

//Catch current dialog options and place them in an array for later use
function SetOptions(nodeIndex)
{
    optionsMapping.clear()
    optionsMapping.resize(0)
    local optionsLength = currentDialog[nodeIndex].next.len()
    printl(optionsLength)
    options.clear()
    options.resize(0)//resize to prevent memory leak
    for (local i = 0; i < optionsLength; i++)
    {
        printl(i)
        if(!("nodeAccess" in currentDialog[currentDialog[nodeIndex].next[i]]) || ("nodeAccess" in currentDialog[currentDialog[nodeIndex].next[i]] && currentDialog[currentDialog[nodeIndex].next[i]].nodeAccess == 1)){
            printl("Access")
            options.insert(i, currentDialog[currentDialog[nodeIndex].next[i]].topLine[0])
            optionsMapping.append(i)
        }else{
            options.insert(i, "/no Access to node/")
            printl("no Access")
            }
    }
    options = ArrayFilter(options, "/no Access to node/")
    DebugPrint("SetOptions:" + ArrayPrint(options))
    DebugPrint("Mapping: " + ArrayPrint(optionsMapping))
}

//Put content of an array into a String and return it. Does not print references in an array.
function ArrayPrint(array){
    local result = "["
    local arrayLength = array.len() - 1
    if(array.len() == 0){
        return result = "[]"
    }
    for(local i = 0; i < arrayLength; i++){
            result = result + array[i] + ", "
        }
    result = result + array[arrayLength] + "]"
    return result
}

//Copy an array into a new one by combining it with a new empty one.
function ArrayCopy(array){
    if(array.len() != 0 || array != null){
        local result = []
        result.extend(array)
        return result
    }
}

function SetTopLine(nodeIndex)
{
    topLine = ArrayCopy(currentDialog[nodeIndex].topLine)
    DebugPrint("SetTopLine: " + ArrayPrint(topLine))
}

function SetSndPath(nodeIndex)
{
    sndPath = ArrayCopy(currentDialog[nodeIndex].sndPath)
    DebugPrint("SetSndPath: " + ArrayPrint(sndPath))
}

function SetSndDur(nodeIndex)
{
    sndDur = ArrayCopy(currentDialog[nodeIndex].sndDur)
    DebugPrint("SetSndDur: " + ArrayPrint(sndDur))
}

//Returns length of options array
function FetchOptionsCount() {
    return options.len()
}

//Progress to next Node and get new dialog info
function FetchDialogInfo(){
    DebugPrint("FetchDialogInfo")
    SetCurrentNode(optionsMapping[selection])
    SetTopLine(currentNodeIndex)
    SetOptions(currentNodeIndex)
    SetSndPath(currentNodeIndex)
    SetSndDur(currentNodeIndex)
    CreateDialogString()
}

//Calls a function tied to the current node
function ExecuteNodeFuntion(){
    if("nodeFunction" in currentDialog[currentNodeIndex]){
        currentDialog[currentNodeIndex].nodeFunction()
    }else{
        printl("No node function")
    }

}

//Create String of availiable options, one marked. Formatting can be applied here.
function OptionsToString(index){
    DebugPrint("OptionsToString")
    local optionsString = "";
    local optionsLength = options.len()
    if(options.len() > 0){
        for (local i = 0; i < optionsLength; i++)
        {
            if (i == index){
                optionsString = optionsString + SELECTION_MARKER_START + "[" + (i + 1) + "] " + options[i] + "\n";//Marked option
            }else {
                optionsString = optionsString + "[" + (i + 1) + "] " + options[i] + "\n";//Unmarked option(s)
                }
        }
    }
    return optionsString;
}

//Put Strings together
function CreateDialogString(){
    DebugPrint("CreateDialogString")
    dialogString = DIALOG_PLACEHOLDER + "\n" + topLine[topLine.len() - 1]  + "\n" + "\n" + OptionsToString(selection);
    DebugPrint(dialogString);
}

//Suspends generator for a give duration and resumes it afterwards
function SuspendGenerator(pauseDur){
    DebugPrint("Generator suspended for " + pauseDur + "s")
    EntFire("Script", "RunScriptCode", "ResumeGenerator()", pauseDur)
}

//Resumes a suspended generator
function ResumeGenerator() {
    DebugPrint("Generator resumed")
    resume generator
}

//Show the dialog text and play the voicelines. Generator function
function PlayNode() {
    DebugPrint("PlayNode")
    ExecuteNodeFuntion()
    local topLineLength = topLine.len()

    for (local i = 0; i<topLine.len(); i++)
    {
        EntFire("HudHint", "AddOutput", "message " + topLine[i], 0)
        ShowDialog()

                //If sound file present play
                if (sndPath[i] != "") {
        DebugPrint("Playing Sound: " + sndPath[i] + "(" + sndDur[i] + "s)")
        EntFire("Sound", "AddOutput", "message " + sndPath[i], 0)
        EntFire("Sound", "PlaySound", "", 0)
        EntFire("Sound", "StopSound", "", sndDur[i])
                }
        yield SuspendGenerator(sndDur[i])
    }

    EntFire("HudHint", "AddOutput", "message " + dialogString, 0)
    EntFire("HudHint", "ShowHudHint", "", 0, activator)

    if(options.len() > 0){
        DebugPrint("Node/s availiable, continuing dialog")
        EntFire("Script", "RunScriptCode", "SetPlayerControl(1)", 0)
    }else{
        DebugPrint("No Node/s availiable, ending dialog")
        EntFire("Script", "RunScriptCode", "EndDialog()", 0)
        }
}

//Change the selected option and show it in dialog
function AddSelection() {
    if (playerControl == true){
        local upperBound = FetchOptionsCount() - 1;
        DebugPrint("upperBound: " + upperBound)
        if (selection < upperBound) {
            selection++;
        }else if(selection == upperBound){
            selection = upperBound;
        }
        CreateDialogString();
        EntFire("HudHint", "AddOutput", "message " + dialogString, 0);
        ShowDialog()
    }
}

//Change the selected option and show it in dialog
function SubstractSelection() {
    if (playerControl == true){
        local lowerBound = 0;
        if (selection > lowerBound) {
            selection--;
        }else if(selection == lowerBound){
            selection = lowerBound;
        }
        CreateDialogString();
        EntFire("HudHint", "AddOutput", "message " + dialogString, 0);
        ShowDialog()
    }
}

//Get new node info based on selected option and play node
function AcceptOption() {
    if (playerControl == true){
        DebugPrint("AcceptOption")
        SetPlayerControl(0)
        FetchDialogInfo()
        generator = PlayNode()
        resume generator
        selection = 0
    }
}

//Changes if the player can control the dialog via game_ui to prevent breaking controlflow
function SetPlayerControl(mode){
    switch(mode){
        case 0: playerControl = false;
                break;
        case 1: playerControl = true;
                break;
    }
    DebugPrint("SetPlayerControl: " + playerControl)
}

//Recall the "ShowHudHint" input since env_hudhint only stays on screen for a few seconds
function RefreshDialog(){
    //DebugPrint("Timer Fired")
    EntFire("HudHint", "ShowHudHint", "", 0, player)
}

//Updates the entranceNode of the dialog for later use
function SaveProgress(){
    if(currentDialog[currentNodeIndex].newEntranceNode != currentDialog[currentDialog.len() - 1]){
        currentDialog[currentDialog.len() - 1] = currentDialog[currentNodeIndex].newEntranceNode
    }
    DebugPrint("Progress saved: " + currentDialog[currentDialog.len() - 1])

}

function SetCurrentDialog(index){
    currentDialog = dialogs[index]
}

//Reset currentNodeIndex and get EntranceNode from dialog
function LoadProgress(index){
    DebugPrint("LoadProgress:")
    SetCurrentDialog(index)
    currentNodeIndex = null;
    startNodeIndex = currentDialog[currentDialog.len() - 1]
    DebugPrint("EntranceNode: " + startNodeIndex)
    FetchDialogInfo()
}

//Starts the dialog
function StartDialog(dialogIndex){
    DebugPrint("StartDialog: " + dialogs[dialogIndex] + " out of " + dialogs)
    EntFire("Button", "Lock", "", 0)
    GetPlayer()
    LoadProgress(dialogIndex)
    EntFire("GameUI", "Activate", "", 0, player)
    ShowDialog()
    EntFire("Timer", "Enable", "", 0)
    generator = PlayNode()
    resume generator//Starts the generator which is initially suspended
}

//Ends dialog
function EndDialog(){
    DebugPrint("EndDialog")
    SaveProgress()
    EntFire("Timer", "Disable", "", 0)
    HideDialog()
    EntFire("GameUI", "Deactivate", "", 0, player)
    EntFire("Button", "Unlock", "", 0)
    selection = 0
    optionsMapping = [0]
}

function test(){
    printl("nodeAccess: " + testDialog[3].nodeAccess)
    printl(version)
}