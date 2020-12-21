# decrement_per_var.lua

## v1.0

*Designed for use with ModSecurity 2.x*

This Lua script allows ModSecurity to correctly decrement multiple variables stored in the same persistent storage collection. This works around a limitation of ModSecurity's built in `deprecatevar` action, which uses the same time stamp variable to evaluate the deprecation logic for *all* variables in a given record in persistent storage. This script creates unique time stamps per variable, preventing the act of deprecating one variable from interfering with other variables.

### Usage

The script is invoked using a SecRule per variable to be decremented, making sure that ModSecurity passes the following 'arguments' to the script:

- the variable to be decremented;
- the interval between each decrement action, in seconds;
- and the amount to decrement the variable by each time.

'Arguments' are passed using transaction variables.

Example usage decrementing `my_variable` in the IP collection:

	SecRule TX:decrement_enabled "@eq 1" \
		"id:10,\
		phase:5,\
		pass,\
		nolog,\
		setvar:'TX.var_name=IP.my_variable',\
		setvar:'TX.dec_interval=10',\
		setvar:'TX.dec_amount=1',\
		exec:/apache/bin/decrement_per_var.lua"
