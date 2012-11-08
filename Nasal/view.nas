##
## E-2C view.nas
##
## Additionnal view utilities for the E-2C.



##
# Moves the Pilot's point of view n cm left or right of his z axis
# standard position. Usefull to see what is hidden by the yoke or the
# windshield frame.

var povPos   = 0;  # actual position index, possible values: -1, 0, 1
var slewTime = 0.4; # slew duration in sec.
var dist     = 0.1; # in meter
var xPosNode = props.globals.getNode("/sim/current-view/x-offset-m");

var xPos = xPosNode.getValue();
var tgts = [xPos - dist, xPos, xPos + dist];

var slidePov = func(d) {
	xPos = xPosNode.getValue();
	var xPosTgt = xPos;
	if ( d < 0 ) {
		if ( povPos == 1 ) {
			xPosTgt = tgts[1];
			povPos -= 1;
		} elsif ( povPos == 0 ) {
			xPosTgt = tgts[0];
			povPos -= 1;
		} else {
			return;
		}
	} else {
		if ( povPos == -1 ) {
			xPosTgt = tgts[1];
			povPos += 1;
		} elsif ( povPos == 0 ) {
			xPosTgt = tgts[2];
			povPos += 1;
		} else {
			return;
		}
	}
	interpolate(xPosNode, xPosTgt, slewTime);
}
