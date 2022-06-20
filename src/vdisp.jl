module vdisp

include("./OutputFormat/OutputFormat.jl")
using .OutputFormat
include("./InputParser.jl")
using .InputParser

using Test
using QML
using Qt5QuickControls_jll
using Qt5QuickControls2_jll
using Observables

export readInputFile, State

# System variables
problemName = Observable("")
model = Observable(0)
foundation = Observable(0)
appliedPressure = Observable(0.0)
center = Observable(true)
foundationLength = Observable(0.0)
foundationWidth = Observable(0.0)
outputIncrements = Observable(false)
saturatedAboveWaterTable = Observable(false)

# Update system variables
# Remove annoying println statements later
setProblemName = on(problemName) do val
    println("Got an update: ", val)
end
setModel = on(model) do val
    println("Got an update: ", val)
end
setFoundation = on(foundation) do val
    println("Got an update: ", val)
end
setAppliedPressure = on(appliedPressure) do val 
    println("Got an update: ", val)
end
setPressurePoint = on(center) do val 
    println("Got an update: ", val)
end
setLength = on(foundationLength) do val 
    println("Got an update: ", val)
end
setWidth = on(foundationWidth) do val 
    println("Got an update: ", val)
end
setOutputIncrements = on(outputIncrements) do val 
    println("Got an update: ", val)
end
setSaturatedAboveWaterTable = on(saturatedAboveWaterTable) do val 
    println("Got an update: ", val)
end

# Load file main.qml
loadqml("./src/UI/main.qml", props=JuliaPropertyMap("problemName" => problemName, "model" => model, "foundation" => foundation, "appliedPressure" => appliedPressure, "center" => center, "foundationLength" => foundationLength, "foundationWidth" => foundationWidth, "outputIncrements" => outputIncrements, "saturatedAboveWaterTable" => saturatedAboveWaterTable))

# Run the app
exec()


#if size(ARGS)[1] == 2
#    readInputFile(ARGS[1], ARGS[2])
#end

"""
    readInputFile(inputPath, outputPath)

Reads and parses input file at inputPath and outputs calculations to file at outputPath
"""
function readInputFile(inputPath::String, outputPath::String)
    # Instantiate OutputData object
    outputData = OutputData(inputPath)

    writeDefaultOutput(outputData, outputPath)
end

end # module
