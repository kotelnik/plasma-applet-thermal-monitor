function getResourcesObjectArray() {
    var cfgResources = plasmoid.configuration.resources
    print('Reading resources from configuration: ' + cfgResources)
    if (!cfgResources) {
        return []
    }
    return JSON.parse(cfgResources)
}
