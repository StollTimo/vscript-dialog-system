IncludeScript("dialog/dialog_info");

const SELECTION_COLOR_RGB = "255 255 255"
const SELECTION_MARKER_START = "< ";
const SELECTION_MARKER_END = " >";

//Current dialog info
startNodeIndex <- 0;
currentNodeIndex <- null;
topLine <- "";
options <- [];
sndPath <- "";
sndDur <- 0;

dialogString <- "";

//Entities
gameText <- null;
sound <- null;
gameUI <- null;
trigger <- null;

//User input
player <- null;
selection <- 0;
playerControl <- false;

//Debug mode
devmode <- false;

//Prints debug messages in console if enabled
function DebugPrint(message){
    if(devmode == true){
        printl(message)
    }
}


function GetPlayer()
{
    player = Entities.FindByClassname(null, "player")
    DebugPrint("GetPlayer: " + player)
}

//Not actually used yet, planning on moving as much as possible out of hammer into vscript
function OnPostSpawn() {

    GetPlayer()
    gameUI = Entities.CreateByClassname("game_ui")

    gameUI.ValidateScriptScope()
    local scope = gameUI.GetScriptScope()
    scope.Add <- AddSelection
    scope.Substract <- SubstractSelection
    scope.Accept <- AcceptOption
    gameUI.ConnectOutput("Add", "PressedForward")
    gameUI.ConnectOutput("Substract", "PressedBack")
    gameUI.ConnectOutput("Accept", "PressedAttack")

    sound = Entities.CreateByClassname("ambient_generic")
    sound.__KeyValueFromInt("Volume", 10)

    sound.ValidateScriptScope()
    local scope = sound.GetScriptScope()
    
    test()
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
        currentNodeIndex = startNodeIndex;
    }else{
        local tempIndex = nodes[currentNodeIndex][3][index]
        local newIndex = nodes[tempIndex][3][0]
        DebugPrint("SetCurrentNode: Old Node: " + currentNodeIndex + " -> new Node: " + newIndex)
        currentNodeIndex = newIndex;
    }
}

function SetOptions(nodeIndex)
{
    options.clear()
    options.resize(0)
    for (local i = 0; i < nodes[nodeIndex][3].len(); i++)
    {
        options.insert(i, nodes[nodes[nodeIndex][3][i]][0])
    }
    /*
    for (local i = 3; i < nodes[nodeIndex].len(); i++)
    {
        options.insert(i - 3, nodes[nodes[nodeIndex][i]][0])
    }
    */
    DebugPrint("SetOptions:" + options)
}

function SetTopLine(nodeIndex)
{
    topLine = nodes[nodeIndex][0]
    DebugPrint("SetTopLine: " + topLine)
}

function SetSndPath(nodeIndex)
{
    sndPath = nodes[nodeIndex][1]
    DebugPrint("SetSndPath: " + sndPath)
}

function SetSndDur(nodeIndex)
{
    sndDur = nodes[nodeIndex][2]
    DebugPrint("SetSndDur: " + sndDur+ "s")
}

function FetchOptionsCount() {
    return options.len()
}

//Progress to next Node and get new dialog info
function FetchDialogInfo(){
    DebugPrint("FetchDialogInfo")
    SetCurrentNode(selection)
    SetTopLine(currentNodeIndex)
    SetOptions(currentNodeIndex)
    SetSndPath(currentNodeIndex)
    SetSndDur(currentNodeIndex)
    CreateDialogString()
}

function startNodeFuntion(nodeIndex){
    
}

//Create String of availiable options, one marked
function OptionsToString(index){
    DebugPrint("OptionsToString")
    local optionsString = "";
    for (local i = 0; i < options.len(); i++)
    {
        if (i == index){
            optionsString = optionsString + SELECTION_MARKER_START + options[i] + SELECTION_MARKER_END + "\n";
        }else if(i != index){
            optionsString = optionsString + "   " + options[i] + "\n";
            }  
    }
    return optionsString;
}

//Put Strings together
function CreateDialogString(){
    DebugPrint("CreateDialogString")
    dialogString = topLine + "\n" + "\n" + OptionsToString(selection);
    DebugPrint(dialogString);
}

function PlayNode() {
    DebugPrint("PlayNode")

    EntFire("HudHint", "AddOutput", "message " + topLine, 0)
    ShowDialog()

    DebugPrint("Playing Sound: " + sndPath + "(" + sndDur + "s)")
    EntFire("Sound", "AddOutput", "message " + sndPath, 0)
    EntFire("Sound", "PlaySound", "", 0)
    EntFire("Sound", "StopSound", "", sndDur)

    if (options.len() > 1){
        DebugPrint("Multiple Nodes found")
    }else {
        DebugPrint("Single Node found")
    }
    EntFire("HudHint", "AddOutput", "message " + dialogString, sndDur)
    EntFire("HudHint", "ShowHudHint", "", sndDur, activator)
    EntFire("Script", "RunScriptCode", "SetPlayerControl(1)", sndDur)

}

//Change the selected option
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

//Change the selected option
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
    DebugPrint("AcceptOption")
    if (playerControl == true){
        SetPlayerControl(0)
        FetchDialogInfo()
        PlayNode()
        selection = 0
    }
}

function SetPlayerControl(mode){
    switch(mode){
        case 0: playerControl = false;
                break;
        case 1: playerControl = true;
                break;
    }
    DebugPrint("SetPlayerControl: " + playerControl)
}

function RefreshDialog(){
    DebugPrint("Timer Fired")
    EntFire("HudHint", "ShowHudHint", "", 0, player)
}

function StartDialog(){

}

function EndDialog(){
    
}

function test(){
    player.EmitSound("player/vo/idf/radio_locknload10.wav")
}