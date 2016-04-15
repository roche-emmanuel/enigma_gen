local oo = require "loop.base"

-- Default logger class
local LoggerBase = oo.class{}

local levels = {}
levels.fatal = 1
levels.error = 2
levels.warn = 3
levels.notice = 4
levels.info = 5
levels.debug = 6
levels.debug0 = 7
levels.debug1 = 8
levels.debug2 = 9
levels.debug3 = 10
levels.debug4 = 11
levels.debug5 = 12

LoggerBase.levels = levels

function LoggerBase:__init()
	local obj = oo.rawnew(self,{})
	obj.indent = 0
	obj.indentStr = "   "
	
	obj.writtenTables = {}; -- used to ensure each table is written only once in a table hierarchy.
	obj.currentLevel = 0
	obj.maxLevel = 5
	return obj
end

local levelStrings = {
	"FATAL","ERROR","WARNING","NOTICE","INFO",
	"DEBUG","DEBUG0","DEBUG1","DEBUG2","DEBUG3","DEBUG4","DEBUG5"
}

function LoggerBase:levelString(lvl)
	return levelStrings[lvl] or "UNKNOWN"
end

function LoggerBase:pushIndent()
	self.indent = self.indent+1
end

function LoggerBase:popIndent()
	self.indent = math.max(0,self.indent-1)
end

function LoggerBase:incrementLevel()
	self.currentLevel = math.min(self.currentLevel+1,self.maxLevel)
	return self.currentLevel~=self.maxLevel; -- return false if we are on the max level.
end

function LoggerBase:decrementLevel()
	self.currentLevel = math.max(self.currentLevel-1,0)
end

--- Write a table to the log stream.
function LoggerBase:writeTable(t)
	local msg = "" -- we do not add the indent on the first line as this would 
	-- be a duplication of what we already have inthe write function.
	
	local id = tostring(t);
	
	if self.writtenTables[t] then
		msg = id .. " (already written)"
	else
		msg = id .. " {\n"
		
		-- add the table into the set:
		self.writtenTables[t] = true
		
		self:pushIndent()
		if self:incrementLevel() then
			for k,v in pairs(t) do
				msg = msg .. string.rep(self.indentStr,self.indent) .. k .. " = ".. self:writeItem(v) .. ",\n" -- 
			end
			self:decrementLevel()
		else
			msg = msg .. string.rep(self.indentStr,self.indent) .. "(too many levels)";
		end
		self:popIndent()
		msg = msg .. string.rep(self.indentStr,self.indent) .. "}"
		
		--local dbg = require "debugger"
		--dbg:assert(,"writtenTable set is invalid.");
	end
	
	return msg;
end

--- Write a single item as a string.
function LoggerBase:writeItem(item)
	if type(item) == "table" then
		-- concatenate table:
		return item.__tostring and tostring(item) or self:writeTable(item)
	else
		-- simple concatenation:
		return tostring(item);
	end
end

--- Write input arguments as a string.
function LoggerBase:write(...)
	self.writtenTables={};
	self.currentLevel = 0
	
	local msg = string.rep(self.indentStr,self.indent);
	local num = select('#', ...)
	for i=1,num do
		local v = select(i, ...)
		msg = msg .. (v~=nil and self:writeItem(v) or "<nil>")
	end
	
	return msg;
end

return LoggerBase
