module Constants

using Observables

export MAX_SUBDIVISIONS, MIN_DX, GAMMA_W, MIN_LAYER_SIZE, PRINT_DEBUG, setDebug, MAX_MATERIAL_COUNT

# InputParser
MAX_SUBDIVISIONS = Observable(50)

# EnterDataStage2
MAX_MATERIAL_COUNT = Observable(5)

# CalculationBehaviour
MIN_DX = 0.01

# VDisp
PRINT_DEBUG = false  # Many descriptive print statements are shown when this is true
function setDebug(debug::Bool)
    global PRINT_DEBUG = debug
end
GAMMA_W = Observable([0.03125, 0.9810])  # Unit weight of water (0.03125 tcf = 62.4 pcf or 9810 N/m^3 = 0.981kN/m^3)
MIN_LAYER_SIZE = Observable([0.0254, 1/12])  # Default minimum layer size (0.0254 m = 2.54 cm or (1/12) ft = 1 in)

end