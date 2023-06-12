# nb_drumcrow  
caw caw caw  
this is a norns mod  
`nb` framework takes notes from scripts and plays different pseudoengines with them  
`nb_drumcrow` is an nb pseudeoengine which turns each output of a monome crow into a drumcrow oscillator  
  
download this like you would any other script  
turn on the mod: go to system > mods > find nb_drumcrow, turn enc3 to the right until you see a +  
this tells norns to load the mod at the next power ON  
go to system > restart and then check the mods, it should have a dot to the left of the name indicating the mod has been loaded  
sometimes it's best to power on crow, power on norns, select script in that order  
find a script that does nb sequencing  
I made a test script called auspicetrainer but you can add nb to any sequencing script on norns  
then select drumcrow from your nb pseudoengines  
then press the on_off parameter to turn on the voice  
in maiden there should be a message "drumcrow 1 engine ON"  
then start playing notes by calling player:note_on() like you would for other nb voices  
in maiden there should be a message "drumcrow 1 note on triggered"  
if you're not hearing sound, try changing model and shape of the drumcrow oscillator to hopefully wake it up, CAW!  
this is a WIP, I've crashed crow plenty but haven't crashed norns yet CAW!  
see drumcrow on lines for documentation of drumcrow parameters  