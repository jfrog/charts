import groovy.json.JsonBuilder

executions {
    helloWorld() { params ->
        try {
            def json = new JsonBuilder()
            json {
                message 'Hello, World!'
            }
            message = json.toPrettyString()
            status = 200
        } catch (e) {
            log.error 'Failed to execute plugin', e
            message = e.message
            status = 500
        }
    }
}