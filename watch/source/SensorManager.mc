using Toybox.Sensor;
using Toybox.System;
using Toybox.ActivityMonitor;

// SensorManager handles all sensor subscriptions for swim tracking:
// - Accelerometer for stroke/motion patterns
// - Heart rate for effort/load trends
// - Pool-length/lap events via activity session
class SensorManager {
    hidden var _heartRate = 0;
    hidden var _accelData = null;
    hidden var _calories = 0;
    hidden var _enabled = false;
    hidden var _listener = null;

    function initialize(listener) {
        _listener = listener;
    }

    // Start sensor subscriptions
    function start() {
        if (_enabled) {
            return;
        }
        _enabled = true;

        // Enable heart rate and accelerometer sensors
        var options = {:period => 1, :accelerometer => {:enabled => true, :sampleRate => 25}};
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensorData));
    }

    // Stop sensor subscriptions
    function stop() {
        if (!_enabled) {
            return;
        }
        _enabled = false;
        Sensor.enableSensorEvents(null);
        Sensor.setEnabledSensors([]);
    }

    // Callback for sensor data updates
    function onSensorData(sensorInfo as Sensor.Info) as Void {
        if (sensorInfo.heartRate != null) {
            _heartRate = sensorInfo.heartRate;
        }

        if (sensorInfo.accel != null) {
            _accelData = sensorInfo.accel;
            if (_listener != null) {
                _listener.onAccelUpdate(_accelData);
            }
        }

        // Retrieve calories from ActivityMonitor info
        var info = ActivityMonitor.getInfo();
        if (info != null && info.calories != null) {
            _calories = info.calories;
        }

        if (_listener != null) {
            _listener.onSensorUpdate(self);
        }
    }

    function getHeartRate() {
        return _heartRate;
    }

    function getAccelData() {
        return _accelData;
    }

    function getCalories() {
        return _calories;
    }

    function isEnabled() {
        return _enabled;
    }
}
