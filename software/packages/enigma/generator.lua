local Class = createClass{name="EnigmaGenerator",bases={"base.Object"}};

local path =require 'utils.path'
local dir =require 'utils.dir'

--[[
Class: enigma.EnigmaGenerator

Loader used to generate an enigma package from a given package configuration.
The package configuration is given as a regular lua table defined in a file passed as parameter 
for this loader.

This class inherits from <loaders.LoaderBase>.

Enigma configuration:
  The Configuration file should contain the following entries:

  - *input_file* : The input file for the boxing.
  - *output_file* : The output file for the boxing.
  - *{files}* : A list of pattern matching all the files that should be included in this package.

This class inherits from <base.Object>.
]]

--[=[
--[[
Constructor: EnigmaGenerator

Create a new instance of the class.

Parameters:
	 No parameter
]]
function EnigmaGenerator(options)
]=]
function Class:initialize(options)
	self._params = {}
	self:check(options and options[1],"Invalid argument list for enigma generator")
	self._params[1] = options[1]

	self:check(options and options[2],"Invalid project path")
	self._projectPath = options[2]

	-- we need to generate a temporary file except if the target description file name is specified.
	self._evbfile = options[3] or path.tmpName().."evb"
	self:debug("Target EVB file: ",self._evbfile)
end

--[[
Function: run

Main run function for this generator.
]]
function Class:run()
	self:debug("Running enigma generator...")
	--  Here we should have receive a parameter, and this parameter should be considered as a file to execute to perform 
	-- the binding generation process:
	self:check(#self._params==1,"Should receive 1 parameter for enigma mode: params=",self._params)

	-- execute the file:
	self:debug("Executing file: ",self._params[1])
	local desc = dofile(self._params[1])
	
	-- self:debug("Received description: ",desc)
	self._desc = desc

	-- prepare a global buffer to store all the evb content:
	self._buf = {}
	self._tagStack = {}
	self._indent = 0

	-- collect the files to embed for this project:
	self:collectFiles()

	-- generate the EVB file:
	self:generateEVB()

	-- write the EVB file:
	self:writeEVB()

	-- create the package:
	self:generatePackages()

	return 0
end

--[[
Function: append

Method used to append some content on the evb buffer.
]]
function Class:append(str)
	table.insert(self._buf,str)
end

--[[
Function: appendLine

Method used to append a complete line to the buffer. This will call <append> internally after adding the newline character
to the provided argument.
]]
function Class:appendLine(str)
	return self:append(str.."\n")
end

--[[
Function: openTag

Mathod used to write an opening XML tag
]]
function Class:openTag(tname)
	table.insert(self._tagStack,tname)
	self:appendLine(string.rep("  ",self._indent).."<"..tname..">")
	self._indent = self._indent+1
end

--[[
Function: closeTag

Method used to write a closing XML tag
]]
function Class:closeTag()
	-- retrieve the latest tag from the stack:
	local tname = table.remove(self._tagStack)
	self:check(tname,"Invalid tag name in closeTag")

	self._indent = math.max(0,self._indent-1)
	self:appendLine(string.rep("  ",self._indent).."</"..tname..">")
end

--[[
Function: writeTag

Method used to write an element text element with a given value
]]
function Class:writeTag(tname,value)
	if type(value) == "boolean" then
		value = value and "true" or "false"
	end
	if type(value) == "string" then
		value = value:gsub("/","\\")
	end
	return self:appendLine(string.rep("  ",self._indent).."<"..tname..">"..value.."</"..tname..">")
end

--[[
Function: writeEVB

Function called to write the buffer content to the EVB file.
]]
function Class:writeEVB()
	self:debug("Writing EVB file...")
	local str = table.concat(self._buf)

	-- test section to convert the file to UTF-16LE:
	-- this doesn't seem to work for now.
	-- local iconv = require "iconv"
	-- local list = iconv.list()
	-- self:debug("List of supported encoding: ",list)
	-- self:debug("old string size: ", #str)
	-- local cd = iconv.open("ISO-8859-1","UTF-16LE")
	-- local cd = iconv.open("UTF-16LE".."//TRANSLIT","ASCII")
	-- local cd = iconv.open("UTF-16LE","ISO-8859-1")
 	-- local nstr, err = cd:iconv(str)
 	-- self:check(err==nil,"Error in iconv conversion: ",err)
 	-- self:debug("new string size: ", #nstr)

	local f = io.open(self._evbfile,"wb")
	self:check(f,"Invalid evb file: ",self._evbfile)
	f:write(str)
	f:close()
end

--[[
Function: collectFiles

Method used to collect all the files and folders that should be embedded in this project.
The function will use the patterns from the config table *files* list to retrieve all the 
elements.
]]
function Class:collectFiles()
	self._files = {type="dir", name="%DEFAULT FOLDER%", children={}}

	for _,filedesc in ipairs(self._desc.files) do

		local root_path = path.normcase(filedesc.root_path)
		local pat = filedesc.pattern

		local folder, pat = path.splitPath(pat)
		local search_path = root_path .. (folder and ('/' .. folder) or "")

		local list = filedesc.recursive and dir.getAllFiles(search_path,pat) or dir.getFiles(search_path,pat)
		
		-- self:debug("Found ",list:size()," elements with pattern=",pat)

		for _,fullpath in ipairs(list) do
			local is_folder = path.isDir(fullpath)

			-- elem = path.relPath(fullpath,root_path)
			elem = fullpath:sub(#root_path+2)
			self:debug("Found element: ", elem)

			-- check if the element contains a sub path:
			cont = self._files.children
			local p1 = elem:find("/")
			
			while p1 do
				-- retrieve the directory name:
				local dname = elem:sub(1,p1-1)
				-- self:debug("Found directory name : ",dname)
				elem = elem:sub(p1+1)
				cont[dname] = cont[dname] or {type="dir", name=dname, children={}}
				p1 = elem:find("/")
				cont = cont[dname].children
			end

			cont[elem] = is_folder and {type="dir", name=elem, children={}} or {name=elem,file=fullpath, action=filedesc.action}
		end
	end

	-- self:debug("Generated file listing: ",self._files.children)
end

--[[
Function: writeFileElement

Method used to write a file element to the EVB buffer.
The element can be an actual file or a folder.
]]
function Class:writeFileElement(elem)
	self:openTag("File")
	if elem.type == "dir" then
		-- this is a folder:
		self:writeTag("Type",3)
		self:writeTag("Name",elem.name)
		self:openTag("Files")
		for _,child in pairs(elem.children) do
			self:writeFileElement(child)
		end
		self:closeTag()
	else
		-- this is a regular file:
		self:writeTag("Type",2)
		self:writeTag("Name",elem.name)
		self:writeTag("File",path.absPath(elem.file,self._projectPath))
		self:writeTag("ActiveX",false)
		self:writeTag("ActiveXInstall",false)
		self:writeTag("Action",elem.action or 0)
		self:writeTag("OverwriteDateTime",false)
		self:writeTag("OverwriteAttributes",false)
		self:writeTag("PassCommandLine",false)
	end
	self:closeTag()
end

--[[
Function: generateEVB

Method called to generate the EVB file content. This method is the main function
used to retrieve the list of files that will be required to build an EVB package.
]]
function Class:generateEVB()
	self:debug("Generating EVB content...")

	-- add the base content:
	self:appendLine('<?xml encoding="utf-8"?>')
	self:openTag("")

	-- write the input file:
	self:writeTag("InputFile",path.absPath(self._desc.input_file,self._projectPath))
	self:writeTag("OutputFile",path.absPath(self._desc.output_file,self._projectPath))

	self:openTag("Files")
	self:writeTag("Enabled",true)
	self:writeTag("DeleteExtractedOnExit",self._desc.delete_extracted_on_exit or false)
	self:writeTag("CompressFiles",self._desc.compress_files or false)

	-- write all the files for this project:
	self:openTag("Files")
	self:writeFileElement(self._files)
	self:closeTag() -- closing </Files>

	self:closeTag() -- closing </Files>

	self:openTag("Packaging")
	self:writeTag("Enabled",self._desc.packaging_enabled or false)
	for _,str in ipairs(self._desc.packages or {}) do
		self:writeTag("Package",str)
	end
	self:closeTag() -- closing </Packaging>

	self:openTag("Options")
	self:writeTag("ShareVirtualSystem",self._desc.share_virtual_system or false)
	self:writeTag("MapExecutableWithTemporaryFile",self._desc.map_exec_temp_file or false)
	self:writeTag("AllowRunningOfVirtualExeFiles",self._desc.allow_running_virtual_exec or false)
	self:closeTag() -- closing </Options>

	self:closeTag() -- closing </>
end

function copyFile(src,dest)
	local fsrc = io.open(src,"rb")
	local fdest = io.open(dest,"wb")

	local str = fsrc:read("*a")
	fdest:write(str)

	fsrc:close()
	fdest:close()
end


--[[
Function: generatePackages

Function called to perform the actual package generation with enigmavbconsole.
]]
function Class:generatePackages()
	self:debug("Generating package...")
	local srctool= root_path.. "tools/enigmavbconsole.exe"
	local desttool = path.tmpName()

	-- self:debug("Writing temp tool ",desttool)

	copyFile(srctool,desttool)

	local cmd = desttool.. " "..self._evbfile

	-- self:debug("Executing command: ",cmd)
	io.flush()

	local f = io.popen(cmd,"r")
	local str = f:read("*a")
	self:debug("Generation result: ", str)
	f:close()

	-- remove the temp tool:
	os.remove(desttool)

	-- os.execute(cmd)
	self:debug("Done generating package.")
end

return Class

