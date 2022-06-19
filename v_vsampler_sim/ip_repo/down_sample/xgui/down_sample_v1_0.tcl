# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "H_DOWN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "H_P" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "W_DOWN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "W_P" -parent ${Page_0}


}

proc update_PARAM_VALUE.H_DOWN { PARAM_VALUE.H_DOWN } {
	# Procedure called to update H_DOWN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.H_DOWN { PARAM_VALUE.H_DOWN } {
	# Procedure called to validate H_DOWN
	return true
}

proc update_PARAM_VALUE.H_P { PARAM_VALUE.H_P } {
	# Procedure called to update H_P when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.H_P { PARAM_VALUE.H_P } {
	# Procedure called to validate H_P
	return true
}

proc update_PARAM_VALUE.TUSER_WIDTH { PARAM_VALUE.TUSER_WIDTH } {
	# Procedure called to update TUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TUSER_WIDTH { PARAM_VALUE.TUSER_WIDTH } {
	# Procedure called to validate TUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.WIDTH { PARAM_VALUE.WIDTH } {
	# Procedure called to update WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH { PARAM_VALUE.WIDTH } {
	# Procedure called to validate WIDTH
	return true
}

proc update_PARAM_VALUE.W_DOWN { PARAM_VALUE.W_DOWN } {
	# Procedure called to update W_DOWN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.W_DOWN { PARAM_VALUE.W_DOWN } {
	# Procedure called to validate W_DOWN
	return true
}

proc update_PARAM_VALUE.W_P { PARAM_VALUE.W_P } {
	# Procedure called to update W_P when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.W_P { PARAM_VALUE.W_P } {
	# Procedure called to validate W_P
	return true
}


proc update_MODELPARAM_VALUE.WIDTH { MODELPARAM_VALUE.WIDTH PARAM_VALUE.WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH}] ${MODELPARAM_VALUE.WIDTH}
}

proc update_MODELPARAM_VALUE.TUSER_WIDTH { MODELPARAM_VALUE.TUSER_WIDTH PARAM_VALUE.TUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TUSER_WIDTH}] ${MODELPARAM_VALUE.TUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.H_DOWN { MODELPARAM_VALUE.H_DOWN PARAM_VALUE.H_DOWN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.H_DOWN}] ${MODELPARAM_VALUE.H_DOWN}
}

proc update_MODELPARAM_VALUE.H_P { MODELPARAM_VALUE.H_P PARAM_VALUE.H_P } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.H_P}] ${MODELPARAM_VALUE.H_P}
}

proc update_MODELPARAM_VALUE.W_DOWN { MODELPARAM_VALUE.W_DOWN PARAM_VALUE.W_DOWN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.W_DOWN}] ${MODELPARAM_VALUE.W_DOWN}
}

proc update_MODELPARAM_VALUE.W_P { MODELPARAM_VALUE.W_P PARAM_VALUE.W_P } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.W_P}] ${MODELPARAM_VALUE.W_P}
}

