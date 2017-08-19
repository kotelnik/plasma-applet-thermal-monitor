function toFahrenheit(celsia) {
    return celsia * (9/5) + 32
}

function toKelvin(celsia) {
    return celsia + 273.15
}

function getTemperature(celsiaDouble, fahrenheitEnabled) {
    var fl = celsiaDouble
    if (temperatureUnit == "°F") {
	fl = toFahrenheit(fl)
    }
    else if (temperatureUnit == "K") {
	fl = toKelvin(fl)
    }
    return Math.round(fl)
}
