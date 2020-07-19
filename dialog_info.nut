
//Precache all soundfiles
function Precache() {
    self.PrecacheScriptSound("custom/Test/TestHome.wav");
    self.PrecacheScriptSound("custom/Test/TestIntroduction.wav");
    self.PrecacheScriptSound("custom/Test/TestKnowing.wav");
    self.PrecacheScriptSound("custom/Test/TestLooks.wav");
    self.PrecacheScriptSound("custom/Test/TestUnit.wav");
    self.PrecacheScriptSound("custom/Test/TestWelcome.wav");
}

//local node = [topLine(String), sndPath(String), sndDur(float), next nodes[1,...,n](Integer)];
local node0 = ["Welcome back, how can I help you today?", "custom/Test/TestWelcome.wav", 3,[1,2,3]];

local node1 = ["Where am I?", "", 1,[4]]
local node2 = ["Who are you?", "", 2,[5]]
local node3 = ["How do you know me?", "", 3,[6]]

local node4 = ["You are at home, where else could you be?", "custom/Test/TestHome.wav", 3, [1,2,3]]
local node5 = ["I am support module A, factory id 1231.01, or as you like to call me 'The stinky one'. I certanly don't approve of the last bit.", "custom/Test/TestIntroduction.wav", 11, [1,2,3]];
local node6 = ["Protocol 43a clearly provides all the necessary information: Inhabitant 3a, female, 11 years of age.", "custom/Test/TestKnowing.wav", 8, [7,8]];

local node7 = ["Do I look like a 11 year old girl to you?", "", 4, [9]];
local node8 = ["I have never been here before", "", 4, [10]];

local node9 = ["Well, looks can be deceiving and you've always had quite the appetite, if I dare to say so.", "custom/Test/TestLooks.wav", 6, [7,8]];
local node10 = ["Don't be silly, nobody in his right mind could forget the experience provided by a special issue housing unit.", "custom/Test/TestUnit.wav", 7, [7,8]];

nodes <- [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9, node10];