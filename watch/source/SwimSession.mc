using Toybox.Activity;
using Toybox.System;
using Toybox.Timer;

// SwimSession tracks swim performance metrics derived from sensors:
// - Lap count and pool length configuration
// - Elapsed time and pace per 100m
// - Stroke detection from accelerometer peaks
// - Heart rate history for load trends
// - Calories from device profile
class SwimSession {
    hidden var _poolLengthMeters = 25;
    hidden var _lapCount = 0;
    hidden var _totalDistanceMeters = 0;
    hidden var _startTimeMs = 0;
    hidden var _elapsedMs = 0;
    hidden var _running = false;
    hidden var _strokeCount = 0;
    hidden var _lastHeartRate = 0;
    hidden var _calories = 0;

    // Stroke detection state
    hidden var _accelThreshold = 1500; // mg threshold for stroke peak
    hidden var _lastPeakTime = 0;
    hidden var _minStrokeIntervalMs = 400; // minimum ms between strokes

    function initialize(poolLengthMeters) {
        _poolLengthMeters = poolLengthMeters;
    }

    function start() {
        _startTimeMs = System.getTimer();
        _running = true;
        _lapCount = 0;
        _totalDistanceMeters = 0;
        _strokeCount = 0;
    }

    function stop() {
        if (_running) {
            _elapsedMs = System.getTimer() - _startTimeMs;
            _running = false;
        }
    }

    // Called when a pool-length lap is completed (e.g., wall touch detected)
    function recordLap() {
        _lapCount += 1;
        _totalDistanceMeters = _lapCount * _poolLengthMeters;
    }

    // Process accelerometer data for stroke detection
    // accelData is an array of [x, y, z] samples
    function processAccel(accelData) {
        if (accelData == null) {
            return;
        }
        var now = System.getTimer();
        for (var i = 0; i < accelData.size(); i++) {
            var sample = accelData[i];
            // Compute magnitude of acceleration
            var mag = _magnitude(sample[0], sample[1], sample[2]);
            if (mag > _accelThreshold) {
                if (now - _lastPeakTime > _minStrokeIntervalMs) {
                    _strokeCount += 1;
                    _lastPeakTime = now;
                }
            }
        }
    }

    hidden function _magnitude(x, y, z) {
        // Approximate magnitude without sqrt for efficiency
        var ax = x < 0 ? -x : x;
        var ay = y < 0 ? -y : y;
        var az = z < 0 ? -z : z;
        // Use max + 0.5*(sum of others) as fast approximation
        var maxVal = ax;
        var sum = ay + az;
        if (ay > maxVal) { maxVal = ay; sum = ax + az; }
        if (az > maxVal) { maxVal = az; sum = ax + ay; }
        return maxVal + sum / 2;
    }

    function updateHeartRate(hr) {
        _lastHeartRate = hr;
    }

    function updateCalories(cal) {
        _calories = cal;
    }

    // Pace in seconds per 100m (0 if no distance)
    function getPacePer100m() {
        var elapsed = getElapsedSeconds();
        if (_totalDistanceMeters == 0 || elapsed == 0) {
            return 0;
        }
        return (elapsed * 100) / _totalDistanceMeters;
    }

    function getElapsedSeconds() {
        if (_running) {
            return (System.getTimer() - _startTimeMs) / 1000;
        }
        return _elapsedMs / 1000;
    }

    function getLapCount() {
        return _lapCount;
    }

    function getTotalDistanceMeters() {
        return _totalDistanceMeters;
    }

    function getStrokeCount() {
        return _strokeCount;
    }

    function getHeartRate() {
        return _lastHeartRate;
    }

    function getCalories() {
        return _calories;
    }

    function getPoolLengthMeters() {
        return _poolLengthMeters;
    }

    function isRunning() {
        return _running;
    }
}
