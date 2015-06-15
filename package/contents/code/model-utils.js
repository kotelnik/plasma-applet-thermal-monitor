// mapping table for optimalization
var modelIndexByKey = {}
var virtualModelKeys = []

/*
var exampleObject1 = {
    sourceName: 'lmsensors/coretemp-isa-0000/Core_0'
    deviceName: 'lmsensors/coretemp-isa-0000/Core_0'
    temperature: 39.8
    warningTemperature: 70
    meltdownTemperature: 80
    doNotShow: true
    childObjects: []
}
var exampleObject2 = {
    sourceName: 'virtual-CPU'
    deviceName: 'CPU'
    temperature: 41.2
    warningTemperature: 70
    meltdownTemperature: 80
    doNotShow: false
    childObjects: [ 'lmsensors/coretemp-isa-0000/Core_0', 'lmsensors/coretemp-isa-0000/Core_1' ]
}
*/

// must be explicitly called in Component.onCompleted method and after that add all sources to engines to start whipping data
function rebuildModelIndexByKey(existingModel) {
    modelIndexByKey = {}
    virtualModelKeys = []
    for (var i = 0; i < existingModel.count; i++) {
        var obj = existingModel.get(i)
        modelIndexByKey[obj.sourceName] = i;
        if (obj.childObjects.length > 0) {
            virtualModelKeys.push(obj.sourceName)
        }
    }
}

function updateTemperatureModel(existingModel, key, temperature) {
    
    print('updating model with temperature: ' + temperature + ', key: ' + key + ', i: ' + modelIndexByKey[key])
    
    existingModel.setProperty(modelIndexByKey[key], 'temperature', temperature)
}

function initModels(savedSourceObjects, temperatureModel) {
    savedSourceObjects.forEach(function (savedSourceObj) {
        var doNotShow = savedSourceObj.parentSource ? true : false
        var newObject = {
            sourceName: savedSourceObj.sourceName,
            deviceName: savedSourceObj.alias,
            temperature: 0,
//             warningTemperature: plasmoid.configuration.warningTemperature,
//             meltdownTemperature: plasmoid.configuration.meltdownTemperature,
            doNotShow: doNotShow,
            childObjects: []
        }
        temperatureModel.append(newObject)
    })
    rebuildModelIndexByKey(temperatureModel)
}

function computeVirtuals(existingModel) {
    virtualModelKeys.forEach(function (sourceName) {
        var virtualObj = existingModel.get(modelIndexByKey[sourceName])
        var temperatureSum = 0
        virtualObj.childObjects.forEach(function (key) {
            temperatureSum += existingModel.get(modelIndexByKey[key]).temperature
        })
        virtualObj.temperature = temperatureSum / virtualObj.childObjects.length
    })
}

function parseHddtemp(hddtempStr) {
    var deviceStrings = hddtempStr.split('||')
    var resultObjects = []
    
    deviceStrings.forEach(function (deviceStr) {
        var splitted = deviceStr.split('|')
        resultObjects.push({
            sourceName: 'hddtemp-' + splitted[1],
            temperature: parseFloat(splitted[3])
        })
    })
    
    return resultObjects
}
