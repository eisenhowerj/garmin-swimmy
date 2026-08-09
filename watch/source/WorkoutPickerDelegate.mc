using Toybox.WatchUi;

// WorkoutPickerDelegate handles input on the workout picker screen.
// Selecting a workout starts a swim session with the default pool length.
class WorkoutPickerDelegate extends WatchUi.BehaviorDelegate {
    hidden var _defaultPoolLength = 25;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        // Start a swim session with default pool length
        var controller = new SwimController(_defaultPoolLength);
        controller.startSwim();

        var view = new SwimMetricsView(controller.getSession());
        var delegate = new SwimSessionDelegate(controller.getSession(), controller.getSensorManager());
        WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        return true;
    }
}
