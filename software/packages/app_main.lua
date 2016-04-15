-- Checkif root_path is valid:
if root_path==nil then
	error "Invalid root path!"
end

-- Setup the module paths:
package.cpath = root_path.."/bin/msvc64/modules/?.dll;"..package.cpath
package.path = package.path..";" .. root_path .. "/?.cfg;" .. root_path .. "/modules/?.lua;"..root_path.."/externals/?.lua;"

-- Load the core module:
print ("Loading core module, using root path: ".. root_path .."...")
require "core"
print ("core module loaded.")
io.flush()

-----------------------------------------------------------------------------------
-- Entry point of the application:

print "Loading logger and tracer..."
io.flush()
log = require("logging.DefaultLogger")()
trace = require("logging.DefaultTracer")()

print "Checking config file..."
io.flush()
config_file = "VBSSim3"
local cfgChecker = require "app.checkConfig"
cfgChecker(config_file)

print "Loading class builder..."
io.flush()
createClass = require("base.ClassBuilder")()

print "Running app..."
io.flush()
app = require "app.VBSSim"
app:run()
print "App running."
io.flush()


if false then

-- if needPaks then
-- -- Before selecting the lua module source we may just load the external package anyway,
-- -- because developers are not supposed to update those frequently:
-- requirePackage "externals"

-- -- We may also load the asset package: internally we will then check if we should use the data
-- -- available for each category (fonts/images/shaders) or just rely on files:
-- requirePackage "mxassets"
-- end

-- core.showMessageBox("Step 2","loading")

-- Now we should decide here if we should be using release packages or developer modules:
-- We use the VBSSIM3_MODULE_PATH environment variable for this.
-- When this variable is set, it should specify additional locations where to look for lua modules.
-- We assume that those locations will contain the mxcore modules at least, thus, in that case, 
-- we do not load the mxcore lua package:
-- local mpath = os.getenv("VBSSIM3_MODULE_PATH")
-- if mpath then
-- 	-- just add the path:
-- 	mpath = mpath:gsub("\\","/") ..";"
-- 	mpath = mpath:gsub(";","/?.lua;")
-- 	core.doLog(level,"Adding module paths: '"..mpath.."'");
-- 	package.path = package.path..";".. mpath
-- elseif needPaks then
-- 	requirePackage "mxcore"
-- end

-- core.showMessageBox("Step 3","loading")

-- After setting the module path, we may add additional common paths:
-- This is done to ensure that core modules will be given higher priority
-- than public modules (found in software/modules):
-- package.path = package.path..";" .. root_path .. "/?.cfg;" .. root_path .. "/modules/?.lua;"..root_path.."/externals/?.lua;"

local log = require "tracer" -- use the tracer as default logging system.

log:info("init","Starting initialization...")

local v = require "version"
core.doLog(level,("Starting VBSSim3 v%d.%d.%d build %d - %s"):format(v.major,v.minor,v.patch,v.build,v.date));

-- core.showMessageBox("Step 4","loading")
require "engine.DefaultHandler"
-- core.showMessageBox("Step 5","loading")

-- -- check if we have an extension available:
-- local extension = os.getenv("VBSSIM3_EXTENSION")
-- if extension then
-- 	--log:debug("init","Loading extension from '",extension,"'")
-- 	-- core.showMessageBox("Step 5","loading")
-- 	dofile(extension)
-- end

-- extension = root_path .. "/VBSSim3.extension"
-- local f = io.open(extension)
-- if f then
-- 	f:close()
-- 	-- log:debug("init","Loading extension from '",extension,"'")
-- 	dofile(extension)
-- end

log:info("init","Lua engine initialization completed.")

-- core.showMessageBox("Step 6","loading")

end



