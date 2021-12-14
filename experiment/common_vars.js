// create variables that will be used a lot

let ppdva = 38; // pixels per degree visual angle (at 20 cm distance, assuming 1cm = 38px)
let timeline = []; // timeline to run on jsPsych.init
let T; // initialize value for trial parameters
let interruptedResponse; // was the response continuously measurable?

// define objects that are common for all files in the ManualInhibitionOnline experiment
// load the target stimulus (an svg file with size 20x20, containing a 15x15 image of the stimulus)
let rightTar = "<div id = 'rightTarDiv'><img src='./img/stimulus.svg' height='84' width='84' class = 'target' style ='transform: translate(250px); position: absolute; margin-top: -42px; margin-left: -42px;'></div>";
let leftTar = "<div id = 'leftTarDiv'><img src='./img/stimulus.svg' height='84' width='84' class = 'target' style = 'transform: translate(-250px); position: absolute; margin-top: -42px; margin-left: -42px;'></div>";

// the invisible target defines the touchable area around the stimulus
let rightTarInvisible = "<div id = 'rightTarInvisibleDiv'><InvisibleDot class = 'targetInvisible' style = 'background-color:rgba(56,153,53,0);  transform: translate(250px); '></InvisibleDot></div>";
let leftTarInvisible = "<div id = 'leftTarInvisibleDiv'><InvisibleDot class = 'targetInvisible' style = 'background-color:rgba(153,31,35,0);  transform: translate(-250px); '></InvisibleDot></div>";
