function create_trials(nTrials, trialDuration, cSide, cAngle, cSplitTime, splitJitter, waitAfter, fixTime) {

    let nT; // number of trials
    let T; // trial collector
    let cS; // condition side counter
    let cA; // condition angle counter
    let ID = 0; // trial ID initialization

    let side_condition; // current side condition
    let angle_condition; // current angle condition

    let test_stimuli = []; // the design structure, stimulus values for each trial

    // loop through trials
    for (nT = 0; nT < nTrials; nT++){
       // loop through flash conditions
        for (cS = 0; cS < cSide.length; cS++){
            side_condition = cSide[cS];
            // loop through jump conditions
            for (cA = 0; cA < cAngle.length; cA++){
                angle_condition = cAngle[cA];


                // assign all values to the current trial
                T = {
                    visibleTarget: function(){
                        if (side_condition === 'l'){
                            return leftTar
                        } else {
                            return rightTar
                        }
                    }(),
                    invisibleTarget: function(){
                        if (side_condition === 'l'){
                            return leftTarInvisible
                        } else {
                            return rightTarInvisible
                        }
                    }(),
                    side: side_condition,
                    angle: angle_condition,
                    fixTime: fixTime*Math.random() + fixTime,
                    splitTime: cSplitTime + (splitJitter * (2 *(Math.random()-0.5))),
                    trialDuration: trialDuration,
                    trialID: ID,
                };
                // save the current trial in our design structure
                test_stimuli.push(T);
                // increase the ID by one
                ID++;
            }
        }
    }
    return test_stimuli;
}