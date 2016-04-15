local oo = require "loop.cached"

-- Default logger class
local LoggerBase = require("logging.LoggerBase")

local DefaultLogger = oo.class({},LoggerBase)

function DefaultLogger:__init()
	local obj = LoggerBase:__init()
	obj = oo.rawnew(self,obj)
	return obj
end

local performLog = function(self,level,...)
	print(self:write("[",self:levelString(level),"] ",...))
end

local performLogV = function(self,level,...)
	if self.verbose then
		print(self:write("[",self:levelString(level),"] ",...))	
	end
end

for k,v in pairs(LoggerBase.levels) do
	DefaultLogger[k] = function(self,...) return performLog(self,v,...); end
	DefaultLogger[k.."_v"] = function(self,...) return performLogV(self,v,...); end
end

return DefaultLogger