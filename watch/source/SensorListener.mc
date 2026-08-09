// SensorListener interface for receiving sensor updates from SensorManager.
// Implement these methods to react to sensor data changes.
class SensorListener {
    // Called when new accelerometer data is available
    function onAccelUpdate(accelData) {}

    // Called on each sensor data update cycle
    function onSensorUpdate(sensorManager) {}
}
