// create variables that will be used a lot

let ppdva = 15; // pixels per degree visual angle (at 20 cm distance, assuming 1cm = 38px)
let timeline = []; // timeline to run on jsPsych.init
let T; // initialize value for trial parameters
let interruptedResponse; // was the response continuously measurable?

// define objects that are common for all files in the ManualInhibitionOnline experiment
// load the target stimulus (an svg file with size 20x20, containing a 15x15 image of the stimulus)
let rightTar = "<div id = 'rightTarDiv'><img src='stimulus.svg' height='20' width='20' class = 'target' style ='transform: translate(300px); position: absolute';></img></div>";
let leftTar = "<div id = 'leftTarDiv'><img src='stimulus.svg' height='20' width='20' class = 'target' style = 'transform: translate(-300px); position: absolute';></img></div>";

// the invisible target defines the touchable area around the stimulus
let rightTarInvisible = "<div id = 'rightTarInvisibleDiv'><InvisibleDot class = 'targetInvisible' style = 'background-color:rgba(56,153,53,0);  transform: translate(200px); '></InvisibleDot></div>";
let leftTarInvisible = "<div id = 'leftTarInvisibleDiv'><InvisibleDot class = 'targetInvisible' style = 'background-color:rgba(153,31,35,0);  transform: translate(-200px); '></InvisibleDot></div>";
