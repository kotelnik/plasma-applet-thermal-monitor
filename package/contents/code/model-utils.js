// mapping table for optimalization
var modelIndexBySourceName = {}

/*
var exampleObject1 = {
    sourceName: 'lmsensors/coretemp-isa-0000/Core_0',
    deviceName: 'lmsensors/coretemp-isa-0000/Core_0',
    temperature: 39.8,
    warningTemperature: 70,
    meltdownTemperature: 80,
    virtual: false,
    childSourceObjects: {}
}
var exampleObject2 = {
    sourceName: 'virtual-CPU',
    deviceName: 'CPU',
    temperature: 41.2,
    warningTemperature: 70,
    meltdownTemperature: 80,
    virtual: true,
    childSourceObjects: {
        'lmsensors/coretemp-isa-0000/Core_0': {
            temperature: 0
        },
        'lmsensors/coretemp-isa-0000/Core_1': {
            temperature: 0
        }
    }
}
*/

/*
 * Fill temperatureModel with "resources" configuration string.
 */
function initModels(savedSourceObjects, temperatureModel) {
    savedSourceObjects.forEach(function (savedSourceObj) {
        var newObject = {
            sourceName: savedSourceObj.sourceName,
            alias: savedSourceObj.alias,
            temperature: 0,
            overrideLimitTemperatures: savedSourceObj.overrideLimitTemperatures,
            warningTemperature: savedSourceObj.overrideLimitTemperatures ? savedSourceObj.warningTemperature : plasmoid.configuration.warningTemperature,
            meltdownTemperature: savedSourceObj.overrideLimitTemperatures ? savedSourceObj.meltdownTemperature : plasmoid.configuration.meltdownTemperature,
            virtual: savedSourceObj.virtual,
            childSourceObjects: savedSourceObj.childSourceObjects || {}
        }
        temperatureModel.append(newObject)
    })
    rebuildModelIndexByKey(temperatureModel)
}

/*
 * Build map for optimizing temperature updating.
 * 
 * Must be explicitly called in Component.onCompleted method and after that add all sources to engines to start whipping data.
 */
function rebuildModelIndexByKey(existingModel) {
    modelIndexBySourceName = {}
    for (var i = 0; i < existingModel.count; i++) {
        var obj = existingModel.get(i)
        modelIndexBySourceName[obj.sourceName] = i
    }
}

/*
 * Sets temperature to existing temperatureModel -> triggers virtual temperature computation and visual update.
 */
function updateTemperatureModel(existingModel, sourceName, temperature) {
    
    var index = modelIndexBySourceName[sourceName]
    if (index === undefined) {
        print('index not found for sourceName: ' + sourceName)
        return
    }
    
    var temperatureToSet = temperature
    
    // try to set virtual temperature
    var currentObj = existingModel.get(index)
    if (currentObj.virtual) {
        
        print('setting partial virtual temperature: ' + temperature)
        
        var childSourceObjects = currentObj.childSourceObjects
        var lastChildSourceObjectsSize = childSourceObjects.length
        
        // update single temperature in child temperatures
        childSourceObjects[sourceName] = temperature
        
        //TODO when tested enough -> remove this check
        if (lastChildSourceObjectsSize < childSourceObjects.length) {
            print('thermalMonitor ERROR: child source object size got bigger by setting partial virtual temperature!!')
        }
        
        // get highest temperature from children temperatures
        temperatureToSet = getHighestFromVirtuals(childSourceObjects)
    }
    
    print('setting property temperature to ' + temperatureToSet + ', sourceName=' + sourceName + ', index=' + index)
    
    // update model
    existingModel.setProperty(index, 'temperature', temperatureToSet)
}

function getHighestFromVirtuals(childSourceObjects) {
    var maxTemperature = 0
    for (var sourceName in virtualObj.childSourceObjects) {
        var newTemperture = virtualObj.childSourceObjects[sourceName].temperature
        if (newTemperture > maxTemperature) {
            maxTemperature = newTemperture
        } 
    }
    return maxTemperature;
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