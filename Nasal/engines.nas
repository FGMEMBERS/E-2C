# Throttle in Reverse position 
# ----------------------------

# Key "Delete" toggles /controls/engines/engine[n]/reverser

var toggle_reverser = func {

}

# Accepted power lever range: power levers cannot be moved to Ground Range
# during flight. Air-ground safety switch on the left main gear.
# Condition lever: GRD STOP disabled when not WoW.





# H/W input is dispatched either to the Yasim regular throttle or the reverse
# thruster throttle

# Compute engines values
# ----------------------



var update_engines = func {
	var n2L = getprop("engines/engine[0]/n2");
	var n2R = getprop("engines/engine[1]/n2");
	var tmtL = n2L * 10.61;
	var tmtR = n2R * 10.61;
	setprop("engines/engine[0]/n2-indicated-temp-deg", tmtL);
	setprop("engines/engine[1]/n2-indicated-temp-deg", tmtR);

}
