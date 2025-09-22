-- detect and test libvips version

local ffi = require "ffi"

local vips_lib = ffi.load(FFI_INCLUDE_PATH .. "/libvips" .. (ffi.os == "OSX" and ".dylib" or ".so"))

local version = {}

version = {
    major = vips_lib.vips_version(0),
    minor = vips_lib.vips_version(1),
    micro = vips_lib.vips_version(2),

    -- test for libvips version is better than x.y .. we use this to turn on
    -- various workarounds for older libvips
    at_least = function(x, y)
        return version.major > x or (version.major == x and version.minor >= y)
    end
}

return version
