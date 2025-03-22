require 'lib/color'
require 'lib/interval'
require 'lib/vec'
require 'lib/ray'
require 'lib/hitrec'

require 'lib/mat'

require 'lib/objects'

require 'lib/camera'

--- @param t number
function math.lerp(t, a, b)
    return (1.0 - t) * a + t * b
end
