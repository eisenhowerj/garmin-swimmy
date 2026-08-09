using Toybox.WatchUi;

// SwimSessionDelegate handles user input during an active swim session.
// Tap/select records a lap (pool wall touch).
// Back stops the session.
class SwimSessionDelegate extends WatchUi.BehaviorDelegate {
    hidden var _controller = null;

    function initialize(controller) {
        BehaviorDelegate.initialize();
        _controller = controller;
    }

    function onSelect() {
        // Record a lap on select/tap
        _controller.getSession().recordLap();
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() {
        // Stop the session, sensors, and timer
        _controller.stopSwim();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
