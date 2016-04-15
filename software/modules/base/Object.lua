local Class = createClass{name="Object",bases="base.ObjectBase"};

--[[
Class: base.Object 

Base class for all other classes.

This class is used as an absolute base for all user defined sub classes.

Note that internally, it will inherit from the ObjectBase class but this part of the inheritance
should be hidden from the user.

This base class also provide access to the global level configuration table.
]]

collectgarbage('setpause',300)
collectgarbage('setstepmul',800)

return Class
