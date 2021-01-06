-- Copyright 2020 Andrew Howe
--
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not
-- use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
-- License for the specific language governing permissions and limitations under
-- the License.
--
--
-- decrement_per_var.lua: Decrements persistent storage variables individually
-- v1.0
-- Written by Andrew Howe (andrew.howe@loadbalancer.org)
--

function main()
	-- Get the name of the variable to be decremented
	local var_name = m.getvar("TX.var_name");

	-- Test if it's possible to get the specified variable and, if not (it
	--   isn't set yet or the user mistyped its name), then return
	if not (m.getvar(var_name)) then
		return nil;
	end
	-- Get the value of the specified variable
	local var_value = tonumber(m.getvar(var_name));

	-- If the variable's value is 0 then there's nothing to do
	if (var_value == 0) then
		return nil;
	end

	-- Get the time interval (seconds) between each decrement action
	local dec_interval = tonumber(m.getvar("TX.dec_interval"));
	-- Get the amount to decrement by each time
	local dec_amount = tonumber(m.getvar("TX.dec_amount"));
	-- Get the current Unix time and store it as a variable
	local current_time = tonumber(m.getvar("TIME_EPOCH"));

	-- Test if it's possible to get the variable's timestamp and, if not,
	--   set one (equal to the current time) and then return
	if not (m.getvar(var_name .. "_LAST_UPDATE_TIME")) then
		m.setvar(var_name .. "_LAST_UPDATE_TIME", current_time);
		return nil;
	end
	-- Get the timestamp of when the specified variable was last updated
	local last_update_time = tonumber(m.getvar(var_name .. "_LAST_UPDATE_TIME"));


	-- Calculate the number of seconds since the variable was last updated
	local time_since_update = current_time - last_update_time;

	-- Test if the time since last update >= interval between decrements
	if time_since_update >= dec_interval then
		-- Calculate by how much the variable needs to be decremented
		local total_dec_amount = math.floor(time_since_update / dec_interval) * dec_amount;
		var_value = var_value - total_dec_amount;
		-- Don't give negative results (interpreted as 'x-=var_value')
		if (var_value < 0) then
			var_value = 0;
		end
		-- Set the variable to its new, decremented value
		m.setvar(var_name, var_value);
		-- Update the variable's 'last updated' timestamp
		m.setvar(var_name .. "_LAST_UPDATE_TIME", current_time);
	end

	return nil;
end
