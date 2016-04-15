local args = {...}

local appName = "enigma.generator" 

print('Running app file '.. appName)
-- 
-- Retrieve the local path to be able to load vstruct:
local scriptFile = debug.getinfo(1).short_src
print("Scritpfile: ",scriptFile)

print("Getting path...")
getPath=function(str,sep)
    sep=sep or'\\'
    return str:match("(.*"..sep..")")
end

-- local path = getPath(scriptFile)
-- print("Using path: ",path)
local path=""

print("OS: ", jit.os)
print("arch: ", jit.arch)

local flavor=""
if jit.os=="Windows" and jit.arch=="x64" then
	flavor="win64"
else
	error("Unsupported OS/arch: ".. jit.os .."/".. jit.arch)
end

root_path = path
print("Root path: ", root_path)

package.path = path.."modules/?.lua;"..path.."externals/?.lua;"..package.path
package.cpath = path.."bin/"..flavor.."/modules/?.dll;".. path.."bin/"..flavor.."/modules/?51.dll;" ..package.cpath

-----------------------------------------------------------------------------------
-- Entry point of the application:

print "Loading logger and tracer..."
io.flush()
log = require("logging.DefaultLogger")()
trace = require("logging.DefaultTracer")()

print "Loading class builder..."
io.flush()
createClass = require("base.ClassBuilder")()

print "Running app..."
io.flush()
app = require(appName)(args)
app:run()
print("Done.")
