function toFahrenheit(celsia) {
    return celsia * (9/5) + 32
}

function getTemperature(temperatureDouble, fahrenheitEnabled) {
    print('getTemperature: ' + temperatureDouble)
    var fl = temperatureDouble
    if (fahrenheitEnabled) {
        fl = toFahrenheit(fl)
    }
    return Math.round(fl)
}
