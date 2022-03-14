state("Toree3D")
{
	int markerA : "UnityPlayer.dll", 0x01671E80, 0xD0, 0x08, 0x18, 0x260, 0x10, 0x50, 0x0C;				//2 if in level, 3 if in menu
	int markerB : "UnityPlayer.dll", 0x01679830, 0x5A8, 0xF0, 0x3D8, 0x1C0, 0x4E0, 0x10, 0x50, 0x0C;	//2 if victory cutscene not playing, 3 if victory cutscene playing
	int paused : "UnityPlayer.dll", 0x016394B8, 0x150, 0x20, 0x20, 0x740, 0x18, 0x88;          			//0 if not paused, 1 if paused
	float time : "UnityPlayer.dll", 0x01679830, 0x5A0, 0x70, 0x1B0, 0x70, 0x28, 0x74;					//elapsed time after starting a level
}
 
startup
{
	settings.Add("split_early", false, "Split immediately upon level completion");
}

init
{
	vars.ready = 0;
	vars.willSplit = 0;
	// Keep track of total run based on game time. (Stored in milliseconds)
	vars.savedTime = 0;
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
	if (old.time > current.time && timer.CurrentSplitIndex == 0 && vars.willSplit == 0) {
		vars.savedTime = 0;
		return true;
	}
	return false;
}

gameTime
{
	// Pause game time while on menu
	if (current.markerA != 2)
	{
		timer.SetGameTime(new TimeSpan(0));
		return TimeSpan.FromMilliseconds(vars.savedTime);
	}

	// gameTime is frames rendered. Game runs at 60 fps
	float ms = current.time * 1000f;
	float oldMs = old.time * 1000f;
	if (ms >= oldMs)
	{
		vars.savedTime += ms - oldMs;
	}

	return TimeSpan.FromMilliseconds(Math.Round(vars.savedTime));
}