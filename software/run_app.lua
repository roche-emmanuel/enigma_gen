local args = {...}

local appName = "enigma.generator" 

-- print('Running app file '.. appName)

print("OS: ", jit.os)
print("arch: ", jit.arch)

local flavor=""
if jit.os=="Windows" and jit.arch=="x64" then
	flavor="win64"
else
	error("Unsupported OS/arch: ".. jit.os .."/".. jit.arch)
end

local path = (root_path:gsub("\\","/")) .."/"
root_path=path
print("Root path: ", path)

package.path = path.."packages/?.lua;"..path.."externals/?.lua;"..package.path
package.cpath = path.."modules/"..flavor.."/?.dll;".. path.."modules/"..flavor.."/?51.dll;" ..package.cpath

-----------------------------------------------------------------------------------
-- Entry point of the application:

print "Loading logger and tracer..."
io.flush()
log = require("logging.DefaultLogger")()
trace = require("logging.DefaultTracer")()

print "Loading class builder..."
io.flush()
createClass = require("base.ClassBuilder")()

-- log:debug("Arguments: ", args)

print "Running app..."
io.flush()
app = require(appName)(args)
app:run()
print("Done.")
io.flush()
