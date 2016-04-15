--[[
 * ObjectBase: a basic object used for LOOP class grounding.
 * Copyright (c) 2011-2013 Emmanuel ROCHE
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or (at
 * your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
 * for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA.

 * Authors: Emmanuel ROCHE.
]]

local oo = require "loop.cached"

local Object = oo.class{}

function Object:__init()
	local obj = oo.rawnew(self,{})
	obj._TRACE_ = "ObjectBase"
	return obj
end

function Object.staticCheck(cond,msg,...)
	if not cond then
		trace:error("StaticCheck",msg,...)
		trace:error("StaticCheck",debug.traceback())
		error("Stopping because a static assertion error occured.")
	end
end

function Object:check(cond,msg,...)
	if not cond then
		msg = msg or "Invalid value detected."
		self:showError(msg,...)
		-- self:backtrace()
		error("Stopping because an assertion error occured.")
	end
	
	return cond
end

function Object:check_default(cond,defval,msg,...)
	if not cond then
		msg = log:write(msg or "Invalid value detected.",...)
		self:showMessage(msg)
		return defval
	end
	
	return cond
end

function Object:checkBool(cond,msg,...)
	self:check(type(cond)=="boolean",msg,...)
end

function Object:showError(msg,...)
	log:fatal(msg,...)
end

function Object:showMessage(msg,...)
	log:info(msg,...)
end

function Object:throw(msg,...)
	log:error(msg,...)
	self:backtrace()
	error("Stopping because error occured: '"..msg.."'\n at: ".. debug.traceback())
end

function Object:deprecated(msg)
	trace:warn(self,"Deprecated: "..msg)
	self:backtrace("warn")
end

function Object:backtrace(level)
	trace[level or "error"](trace,self,debug.traceback("",3))
end

function Object:getClassOf(obj)
	return oo.classof(obj or self)
end

function Object:isInstanceOf(class,obj)	
	local obj_class
	if obj~=nil then
		obj_class = oo.classof(obj)
	else
		obj_class = oo.classof(self)	
	end
	
	return obj_class==class or oo.subclassof(obj_class,class)
end

function Object:soft_no_impl(msg)
	self:warn(msg or "The function called is not implemented yet.")
	self:backtrace()
end

function Object:no_impl()
	self:error("The function called is not implemented yet.")
	self:backtrace()
	error("Stopping because error occured.")
end

for k,v in pairs(trace.levels) do
	Object[k] = function(self,msg,...) 
		return trace[k](trace,self,msg,...); end
	Object[k.."_v"] = function(self,msg,...) 
		return trace[k.."_v"](trace,self,msg,...); end
end

local prof = nil

function Object:p_start(sname)
	if not prof then
		prof = require "base.Profiler"
	end
	
	--prof:start(self._TRACE_ .. " - " .. sname)
end

function Object:p_stop()
	--prof:stop()
end

return Object
