using Toybox.WatchUi;

// SwimSessionDelegate handles user input during an active swim session.
// Tap/select records a lap (pool wall touch).
// Back stops the session.
class SwimSessionDelegate extends WatchUi.BehaviorDelegate {
    hidden var _session = null;
    hidden var _sensorManager = null;

    function initialize(session, sensorManager) {
        BehaviorDelegate.initialize();
        _session = session;
        _sensorManager = sensorManager;
    }

    function onSelect() {
        // Record a lap on select/tap
        _session.recordLap();
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() {
        // Stop the session and sensors
        _session.stop();
        _sensorManager.stop();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
