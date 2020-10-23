/*
Includes all dialog data, such as soundfiles, text, duration and the layout of the dialog tree
*/

//Precache all soundfiles
function Precache() {
    self.PrecacheScriptSound("custom/Test/TestHome.wav")
    self.PrecacheScriptSound("custom/Test/TestIntroduction.wav")
    self.PrecacheScriptSound("custom/Test/TestKnowing.wav")
    self.PrecacheScriptSound("custom/Test/TestLooks.wav")
    self.PrecacheScriptSound("custom/Test/TestUnit.wav")
    self.PrecacheScriptSound("custom/Test/TestWelcome.wav")
    self.PrecacheScriptSound("custom/Test/TestLeave.wav")
    self.PrecacheScriptSound("custom/Test/TestWelcomeBack.wav")
}

// using tables
// access: node[0].topLine
testDialog <-
[
	{
		topLine = ["Welcome back, how can I help you today?"],
		sndPath = ["custom/Test/TestWelcome.wav"],
		sndDur = [3.0],
		next = [1,2,3,12],
		newEntranceNode = 0
	},
	{
		topLine = ["Where am I?"],
		sndPath = [""],
		sndDur = 1.0,
		next = [4],
		newEntranceNode = 0
	},
	{
		topLine = ["Who are you?"],
		sndPath = [""],
		sndDur = [1.0],
		next = [5],
		newEntranceNode = 0
	},
    {
		topLine = ["How do you know me?"],
		sndPath = [""],
		sndDur = [1.0],
		next = [6],
		newEntranceNode = 0
	},
    {
		topLine = ["You are at home, where else could you be?"],
		sndPath = ["custom/Test/TestHome.wav"],
		sndDur = [3.0],
		next = [1,2,3,12],
		newEntranceNode = 0
	},
    {
		topLine = ["I am support module A, factory id 1231.01, or as you like to call me 'The stinky one'. I certanly don't approve of the last bit."],
		sndPath = ["custom/Test/TestIntroduction.wav"],
		sndDur = [11.0],
		next = [1,2,3,12],
		newEntranceNode = 0
	},
    {
		topLine = ["Protocol 43a clearly provides all the necessary information: Inhabitant 3a, female, 11 years of age."],
		sndPath = ["custom/Test/TestKnowing.wav"],
		sndDur = [8.0],
		next = [7,8,12],
		newEntranceNode = 0
	},
    {
		topLine = ["Do I look like a 11 year old girl to you?"],
		sndPath = [""],
		sndDur = [4.0],
		next = [9],
		newEntranceNode = 0
	},
    {
		topLine = ["I have never been here before"],
		sndPath = [""],
		sndDur = [4.0],
		next = [10],
		newEntranceNode = 0
	},
    {
		topLine = ["Well, looks can be deceiving and you've always had quite the appetite, if I dare to say so."],
		sndPath = ["custom/Test/TestLooks.wav"],
		sndDur = [6.0],
		next = [7,8,12],
		newEntranceNode = 0
	},
    {
		topLine = ["Don't be silly, nobody in his right mind could forget the experience provided by a special issue housing unit."],
		sndPath = ["custom/Test/TestUnit.wav"],
		sndDur = [7.0],
		next = [7,8,12],
		newEntranceNode = 0
	},
    {
		topLine = ["Until next time"],
		sndPath = ["custom/Test/TestLeave.wav"],
		sndDur = [2.0],
		next = [],
		newEntranceNode = 13
	},
    {
		topLine = ["[Leave]"],
		sndPath = [""],
		sndDur = [1.0],
		next = [11],
		newEntranceNode = 0
	},
    {
		topLine = ["Once again we meet"],
		sndPath = ["custom/Test/TestWelcomeBack.wav"],
		sndDur = [2.0],
		next = [1,2,3,12],
		newEntranceNode = 0
	},
    0
]

dialogs <- [testDialog]