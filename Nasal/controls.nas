
# TACAN: panel controls
# ---------------------

var tacan_XYtoggle = func {
	if ( E_2C.TcXY.getValue() == "X" ) {
		E_2C.TcXY.setValue( "Y" );
		TcXYSwitch.setValue( 1 );
	} else {
		E_2C.TcXY.setValue( "X" );
		TcXYSwitch.setValue( 0 );
	}
}

var tacan_tenth_adjust = func(n) {
	var tenths = getprop( "instrumentation/tacan/frequencies/selected-channel[2]" );
	var hundreds = getprop( "instrumentation/tacan/frequencies/selected-channel[1]" );
	var value = (10 * tenths) + (100 * hundreds);
	var new_value = value + n;
	var new_hundreds = int(new_value/100);
	var new_tenths = (new_value - (new_hundreds*100))/10;
	setprop( "instrumentation/tacan/frequencies/selected-channel[1]", new_hundreds );
	setprop( "instrumentation/tacan/frequencies/selected-channel[2]", new_tenths );
}



