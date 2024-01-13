# nb_drumcrow  
caw caw caw  
this is a norns mod  
`nb` is a voice library for norns.  
`nb_drumcrow` is turns each output of a monome crow into a drumcrow oscillator  
  
1) download this like you would any other script  
2) turn on the mod: go to system > mods > find nb_drumcrow, turn enc3 to the right until you see a +. this tells norns to load the mod at the next power ON  
3) go to system > restart and then check the mods, it should have a dot . to the left of the name indicating the mod has been loaded  
4) find a script that supports nb  
5) go to your params and select drumcrow from your nb voices  
6) press the on_off parameter to turn on the voice. in maiden there should be a message "drumcrow 1 engine ON"  
7) start playing notes by calling player:note_on() like you would for other nb voices  
8) in maiden there should be a message "drumcrow 1 note on triggered" (I should probably turn those off...)  

if you're not hearing sound, try changing model and shape of the drumcrow oscillator to hopefully wake it up, CAW!  
this is a WIP, I've crashed crow plenty but haven't crashed norns yet CAW!  
see drumcrow on lines for documentation of drumcrow parameters  

drumcrow engine works continuously updating the ASL outputs on crow. It updates the outputs roughly every 0.006 seconds. Each update applies the current value of the note, amp, and lfo modulation sources to the crow output. The standalone version of drumcrow (used with druid or teletype) seems to have smoother envelopes and lfos, whereas the nb_drumcrow version the envelopes are not updated nearly as often so the envelopes and lfo can't oscillate as fast and are steppier at higher frequencies. I'm not sure why, but ultimately the better design would be to scrap the this style of engine and try to do as much as possible inside the ASL table as possible using dynamic variables and mutators. Triggers, sequencers, step changing control rate modulation could be done from a lua updating loop, but for snappier envelopes and audio rate lfos, a solution inside of ASL would be better. Decay envelopes can be created by multiplying decimal values less than 1. A simple rising ramp LFO could be created using mutators step and wrap. 
