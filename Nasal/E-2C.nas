var UPDATE_PERIOD = 0.05;




var TrueHdg          = props.globals.getNode("orientation/heading-deg");
var MagHdg           = props.globals.getNode("orientation/heading-magnetic-deg");
var MagDev           = props.globals.getNode("orientation/local-mag-dev", 1);
var Tc               = props.globals.getNode("instrumentation/tacan");
var TcTrueHdg        = Tc.getNode("indicated-bearing-true-deg");
var TcMagHdg         = Tc.getNode("indicated-mag-bearing-deg", 1);
var TcXY             = Tc.getNode("frequencies/selected-channel[4]");
var TcXYSwitch       = props.globals.getNode("sim/model/E-2C/controls/instrumentation/tacan/xy-switch", 1);
var Vac_inhg         = "systems/vacuum[2]/suction-inhg";

var mag_dev = 0;









# Compute local magnetic deviation.
var local_mag_deviation = func {
	var true = TrueHdg.getValue();
	var mag = MagHdg.getValue();
	mag_dev = geo.normdeg( mag - true );
	if ( mag_dev > 180 ) mag_dev -= 360;
	MagDev.setValue(mag_dev); 
}

var tacan_update = func {
	# Get magnetic tacan bearing.
	var true_bearing = TcTrueHdg.getValue();
	var mag_bearing = geo.normdeg( true_bearing + mag_dev );
	if ( true_bearing != 0 ) {
		TcMagHdg.setDoubleValue( mag_bearing );
	} else {
		TcMagHdg.setDoubleValue(0);
	}
}

var vacuum_update = func {
	# used to fake the Attitude Indicator powering
	# FIXME: when electrical system up and running
	setprop(Vac_inhg, 5);
}



# Lighting ################
aircraft.data.add(
	"controls/lighting/instruments-primary-norm",
	"controls/lighting/instruments-secondary-norm",
	"controls/lighting/panel-norm"
	);



# Fuel dump.
var tank_lbs_L = "consumables/fuel/tank[0]/level-lbs";
var tank_lbs_R = "consumables/fuel/tank[1]/level-lbs";
var dumprate_lbs_min = getprop("sim/model/E-2C/controls/fuel/fuel-dump-rate") / 2; # has to be shared between 2 tanks.
var dumprate_lbs_loop = dumprate_lbs_min / 60 * 6 * UPDATE_PERIOD;
var dump_limit =  getprop("sim/model/E-2C/controls/fuel/fuel-dump-limit-lbs");

var fuel_update = func {
	var dumping_fuel_sw = getprop("sim/model/E-2C/controls/fuel/fuel-dump");
	if (dumping_fuel_sw) {
		var level_lbs_L = getprop(tank_lbs_L);
		var level_lbs_R = getprop(tank_lbs_R);
		if ( level_lbs_L > dump_limit ) {
			var new_level_L = level_lbs_L - dumprate_lbs_loop;
			setprop(tank_lbs_L, new_level_L);
		}
		if ( level_lbs_R > dump_limit ) {
			var new_level_R = level_lbs_R - dumprate_lbs_loop;
			setprop(tank_lbs_R, new_level_R);
		}
		if (( level_lbs_R < dump_limit ) and ( level_lbs_R < dump_limit )) {
			setprop("sim/model/E-2C/controls/fuel/fuel-dump", 0)
		}
	}
}


# Main loop ###############
var cnt = 0;

var main_loop = func {
	cnt += 1;
	# done each 0.05 sec.
	var a = cnt / 2;


	if ( ( a ) == int( a )) {
		# done each 0.1 sec, cnt even.
		tacan_update();
		chronograph.update_chrono();
		if (( cnt == 6 ) or ( cnt == 12 )) {
			# done each 0.3 sec.
			fuel_update();
			if ( cnt == 12 ) {
				# done each 0.6 sec.
				local_mag_deviation();
				cnt = 0;
			}
		}
	} else {
		# done each 0.1 sec, cnt odd.
		vacuum_update();
		update_engines();
		if (( cnt == 5 ) or ( cnt == 11 )) {
			# done each 0.3 sec.
			if ( cnt == 11 ) {
				# done each 0.6 sec.
			}
		}
	}
	settimer(main_loop, UPDATE_PERIOD);
}


# Init ####################
var init = func {
	print("Initializing E-2C Systems");
	local_mag_deviation();
	# launch
	settimer(main_loop, 0.5);
}

setlistener("sim/signals/fdm-initialized", init);

# Miscelaneous definitions and tools ############

# warning lights medium speed flasher
# -----------------------------------
aircraft.light.new("sim/model/E-2C/lighting/warn-medium-lights-switch", [0.3, 0.2]);
setprop("sim/model/E-2C/lighting/warn-medium-lights-switch/enabled", 1);

# wing fold
# ---------
var WingFold    = aircraft.door.new("surface-positions/wing-fold", 12);

var mp_wing_pos = props.globals.getNode("surface-positions/wing-fold-pos-norm", 1);
mp_wing_pos.alias(props.globals.getNode("surface-positions/wing-fold/position-norm"));

# Override standard controls.wingsDown() so the regular keybindings trigger the
# whole sequence.
controls.wingsDown = func(n) {
	if ( n == -1 ) {
		WingFold.open();
	} elsif ( n == 1 ) {
		WingFold.close();
	} 
}


