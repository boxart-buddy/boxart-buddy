-- handle the libvips error buffer

local ffi = require "ffi"

local vips_lib = ffi.load(FFI_INCLUDE_PATH .. "/libvips" .. (ffi.os == "OSX" and ".dylib" or ".so"))

local verror = {
    -- get and clear the error buffer
    get = function()
        local errstr = ffi.string(vips_lib.vips_error_buffer())
        vips_lib.vips_error_clear()

        return errstr
    end
}

return verror
