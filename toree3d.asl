state("Toree3D")
{
	int markerA : "UnityPlayer.dll", 0x118AD80, 0xE40, 0xD4, 0x7C, 0x38;         //2 if in level, 3 if in menu
	int markerB : "UnityPlayer.dll", 0x118AD80, 0xDF8, 0x1C4, 0x58, 0x1E8;       //2 if victory cutscene not playing, 3 if victory cutscene playing
	int paused : "UnityPlayer.dll", 0x11AC740, 0x1E4, 0x34, 0x0, 0x4A8;          //0 if not paused, 1 if paused
	float time : "UnityPlayer.dll", 0x11B58E0, 0x125C;                           //elapsed time after starting a level
}

startup
{
	settings.Add("split_early", false, "Split immediately upon level completion");
}

init
{
	vars.ready = 0;
	vars.willSplit = 0;
}

update
{
	if ((current.markerA == 3) || (current.paused == 1)) {vars.ready = 1;}
	if ((current.markerB == 3) && (old.markerB == 2)) {vars.willSplit = 1;}
}

start
{
	return (current.markerA == 2) && (current.time < 0.125) && (vars.ready == 1);
}

split
{
	if (vars.willSplit == 1) {
		if (timer.CurrentSplitIndex == 8 || settings["split_early"]) {
			vars.willSplit = 0; return true;
		} else {
			if ((current.markerA == 3) && (old.markerA == 2)) {vars.willSplit = 0; return true;}
		}
	}
}

reset
{
	return (old.time > current.time) && (timer.CurrentSplitIndex == 0) && (vars.willSplit == 0);
}