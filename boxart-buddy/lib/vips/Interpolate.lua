-- make image interpolators, see affine

local ffi = require "ffi"

local verror = require "vips.verror"
local vobject = require "vips.vobject"

local vips_lib = ffi.load(FFI_INCLUDE_PATH .. "/libvips" .. (ffi.os == "OSX" and ".dylib" or ".so"))

local Interpolate = {}

Interpolate.vobject = function(self)
    return ffi.cast(vobject.typeof, self)
end

Interpolate.new = function(name)
    -- there could potentially be other params here, but ignore that for now
    local interpolate = vips_lib.vips_interpolate_new(name)
    if interpolate == nil then
        error("no such interpolator\n" .. verror.get())
    end

    return vobject.new(interpolate)
end

return ffi.metatype("VipsInterpolate", {
    __index = Interpolate
})


