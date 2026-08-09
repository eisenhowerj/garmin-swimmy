using Toybox.System;
using Toybox.WatchUi;
using Toybox.Timer;

// SwimController coordinates the swim session, sensor manager, and UI updates.
// It acts as the SensorListener to route data into SwimSession.
class SwimController extends SensorListener {
    hidden var _session = null;
    hidden var _sensorManager = null;
    hidden var _updateTimer = null;
    hidden var _workout = null;
    hidden var _milestoneDetector = null;

    function initialize(poolLengthMeters, workout) {
        _session = new SwimSession(poolLengthMeters);
        _sensorManager = new SensorManager(self);
        _workout = workout;
        _milestoneDetector = new MilestoneDetector(workout, poolLengthMeters);
    }

    function startSwim() {
        _session.start();
        _sensorManager.start();
        _milestoneDetector.onSessionStart(System.getTimer());

        // Periodic UI refresh every second
        _updateTimer = new Timer.Timer();
        _updateTimer.start(method(:onTimerTick), 1000, true);
    }

    function stopSwim() {
        if (_updateTimer != null) {
            _updateTimer.stop();
            _updateTimer = null;
        }
        _session.stop();
        _sensorManager.stop();
    }

    function onTimerTick() as Void {
        WatchUi.requestUpdate();
    }

    // SensorListener: accelerometer data
    function onAccelUpdate(accelData) {
        _session.processAccel(accelData);
    }

    // SensorListener: heart rate / calories
    function onSensorUpdate(sensorManager) {
        _session.updateHeartRate(sensorManager.getHeartRate());
        _session.updateCalories(sensorManager.getCalories());
    }

    // Record a lap and check for milestones
    function recordLap() {
        _session.recordLap();
        _milestoneDetector.onLapRecorded(_session, System.getTimer());
    }

    function getSession() {
        return _session;
    }

    function getSensorManager() {
        return _sensorManager;
    }

    function getWorkout() {
        return _workout;
    }
}
