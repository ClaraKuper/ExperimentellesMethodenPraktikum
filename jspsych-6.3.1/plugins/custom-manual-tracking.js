/**
 * custom-manual-tracking
 * Clara Kuper
 *
 * plugin for displaying a moving stimulus that splits half way
 * based on the html-button-response plugin by Josh de Leeuw
 * following Spering, Gegenfurthner und Kerzel 2006
 *
 **/

jsPsych.plugins["manual-tracking"] = (function() {

  let plugin = {};

  plugin.info = {
    name: 'manual-tracking',
    description: '',
    parameters: {
      stimulus: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        pretty_name: 'stimulus',
        default: undefined,
        description: 'The HTML string to be displayed'
      },
      responseArea: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        pretty_name: 'response area',
        default: undefined,
        description: 'Invisible Area that serves as touch response area.'
      },
      splitTime: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'split time',
        default: 500,
        array: false,
        description: 'The time in ms when a second dot spilts off from the first.'
      },
      angle: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'split angle',
        default: null,
        description: 'The angle at which the new point splits off from the old one.'
      },
      trial_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Trial duration',
        default: null,
        description: 'How long to show the trial.'
      },
      side: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'stimulus side',
        default: undefined,
        description: 'The side where the dot appears first.'
      },
      speed: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'stimulus speed',
        default: undefined,
        description: 'The speed at which the stimulus moves in px/sec.'
      },
      waitAfter: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'wait after',
        default: undefined,
        description: 'How long to wait after the trial ended.'
      },
      fixTime: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'fixation time',
        default: undefined,
        description: 'How long to wait after the first click.'
      },
      shiftBeforeStart: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'start shift',
        default: 0,
        description: 'How much the stimulus shifts inwards or outwards before it starts moving.'
      },
      dummy: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'dummy mode',
        default: false,
        description: 'if running in dummy mode, we track the mouse',
      },
    }
  }

  plugin.trial = function(display_element, trial) {

    // display stimulus
    let html = '<div id="custom-manual-tracking-stimulus">' + trial.stimulus + '</div>';

    // display distractor stimulus
    html += '<div id="custom-manual-tracking-distractor">' + trial.stimulus + '</div>';

    // response area
    html += '<div id="custom-manual-tracking-response">' + trial.responseArea + '</div>';

    // get the html on the screen
    display_element.innerHTML = html;

    // initialize variables
    let start_position;   // the initial location of the dot
    let target_position;  // the position of the target (updated)
    let distractorX_position; // the X position of the distractor (updated)
    let distractorY_position; // the Y position of the distractor (updated)
    let start_time;       // the time point when the experiment started
    let move_dir;         // the direction in which the dot moves
    let target_boundaries; // the boundaries of the moving target
    let mouse_x = null;   // the x position of the mouse
    let mouse_y = null;   // the y position of the mouse
    let mouse_trace_x = []; // the saved information about the x mouse trace
    let mouse_trace_y = []; // the saved information about the y mouse trace
    let touch;

    let responseOn;
    let responseMove;

    // boolean check
    interruptedResponse = false;

    // define the events the screen responds to
    if (trial.dummy){
      responseOn = 'click';
      responseMove = 'mousemove';
    } else {
      responseOn = 'touchstart';
      responseMove = 'touchmove';
    }


    // define the starting position of the dots
    let target_transform = document.getElementsByClassName('target')[0].style.transform
    let target_filter = target_transform.split('(')[1];
    start_position = parseInt(target_filter.split('px')[0]);

    // define in which direction we will move
    if (trial.side === 'l'){
      move_dir = 1;
    } else {
      move_dir = -1;
    }

    // change the start position such that the stimulus jumps 1 dva in the opposite direction before it starts moving (facilitating pursuit)
    start_position = start_position + (-1 * move_dir * trial.shiftBeforeStart);

    // the target and the distractor are both at start position
    target_position = start_position;
    distractorX_position = start_position;
    distractorY_position = 0;

    // define how much we already moved
    let nMoves = 0;

    // define how often we update the screen
    let refreshRate = 33;

    // define how many pixels we want to move per refresh
    let pixperrefresh = (trial.speed/1000) * refreshRate;

    // define how many pixels on x and y the dot moves after separation
    let xpixelangle = Math.cos(trial.angle * Math.PI / 180) * pixperrefresh;
    let ypixelangle = Math.sin(trial.angle * Math.PI / 180) * pixperrefresh;

    // add event listeners to buttons
    display_element.querySelector('#custom-manual-tracking-response').addEventListener(responseOn, firstClick);

    // and to the mouse
    document.addEventListener(responseMove, onMouseUpdate, false);

    function onMouseUpdate(e) {
      if (trial.dummy){
        mouse_x = e.pageX;
        mouse_y = e.pageY;
      } else{
        let evt = (typeof e.originalEvent === 'undefined') ? e : e.originalEvent;
        touch = evt.touches[0] || evt.changedTouches[0];
        mouse_x = touch.pageX;
        mouse_y = touch.pageY;
      }

    }

    // function to handle responses by the subject
    function firstClick(e) {
      jsPsych.pluginAPI.clearAllTimeouts()

      onMouseUpdate(e);

      // start move dot & monitor mouse after a delay
      jsPsych.pluginAPI.setTimeout(function(){
        start_time = performance.now();
        move_dot();
        }, trial.fixTime);
      // disable the start button after a response
      document.querySelector('#custom-manual-tracking-response').removeEventListener('click', firstClick);
    }

    function move_dot() {
      // change the position of the visible and the invisible dot according to the speed in the plugin
      target_position = target_position + pixperrefresh * move_dir;
      if (performance.now() - start_time < trial.splitTime){
        distractorX_position = distractorX_position + pixperrefresh * move_dir;
      } else {
        distractorX_position = distractorX_position + xpixelangle * move_dir;
        distractorY_position = distractorY_position + ypixelangle * move_dir;
      }

      document.getElementsByClassName('target')[0].style.transform = 'translate(' + target_position + 'px)';
      document.getElementsByClassName('targetInvisible')[0].style.transform = 'translate(' + target_position + 'px)';
      document.getElementsByClassName('target')[1].style.transform = 'translate(' + distractorX_position + 'px, ' + distractorY_position + 'px)';

      nMoves += 1;

      // check the position
      // update the position of the bounding rectangle
      target_boundaries = document.getElementsByClassName('targetInvisible')[0].getBoundingClientRect();

      jsPsych.pluginAPI.setTimeout(move_dot, refreshRate);

      // compare the current position of the mouse
      if (mouse_x >= target_boundaries.left && mouse_x <= target_boundaries.right &&
          mouse_y <= target_boundaries.bottom && mouse_y >= target_boundaries.top){
        mouse_trace_x.push(mouse_x);
        mouse_trace_y.push(mouse_y);
      } else {
        interruptedResponse = true;
        end_trial()
      }

      // set timeouts on the first execution
      if (Math.abs(nMoves) == 1){
        // timeout to end the trial
        jsPsych.pluginAPI.setTimeout(function () {
          end_trial();
          }, trial.trial_duration);
      }
    }

    // function to end trial when it is time
    function end_trial() {

      // kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();

      // gather the data to store for the trial
      let trial_data = {
        dur: performance.now() - start_time,
        start_time: start_time,
        mouse_trace_x: mouse_trace_x,
        mouse_trace_y: mouse_trace_y,
        interruptedResponse: interruptedResponse,
        pixperrefresh: pixperrefresh,
        angle: angle,
        side: side,
        start_position: start_position,
        splitTime: splitTime,
        fixTime: fixTime,
        speed: speed,
      };

      // clear the display
      display_element.innerHTML = '';

      // move on to the next trial
      jsPsych.finishTrial(trial_data);
    }
  };

  return plugin;
})();
