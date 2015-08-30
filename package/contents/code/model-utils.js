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
    
    var index = modelIndexByKey[key]
    if (index === undefined) {
        print('index not found for key: ' + key)
        return
    }
    
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

var UDISKS_VIRTUAL_PATH_PREFIX = 'udisks/'
var UDISKS_PATH_START_WITH = '/org/freedesktop/UDisks2/drives/'
var UDISKS_DEVICES_CMD = 'qdbus --system org.freedesktop.UDisks2 | grep ' + UDISKS_PATH_START_WITH
var UDISKS_TEMPERATURE_CMD_PATTERN = 'qdbus --system org.freedesktop.UDisks2 {path} org.freedesktop.UDisks2.Drive.Ata.SmartTemperature'

function parseUdisksPaths(udisksPaths) {
    var deviceStrings = udisksPaths.split('\n')
    var resultObjects = []
    
    if (deviceStrings) {
        deviceStrings.forEach(function (path) {
            if (path) {
                resultObjects.push({
                    cmd: UDISKS_TEMPERATURE_CMD_PATTERN.replace('{path}', path),
                    name: path.substring(UDISKS_PATH_START_WITH.length)
                })
            }
        })
    }
    
    return resultObjects
}

function getUdisksTemperatureCmd(diskLabel) {
    return UDISKS_TEMPERATURE_CMD_PATTERN.replace('{path}', UDISKS_PATH_START_WITH + diskLabel)
}

function getCelsiaFromUdisksStdout(stdout) {
    var temperature = parseFloat(stdout)
    if (temperature <= 0) {
        return 0
    }
    return Math.round(toCelsia(temperature))
}

function toCelsia(kelvin) {
    return kelvin - 273.15
}