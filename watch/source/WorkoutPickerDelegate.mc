using Toybox.WatchUi;

// WorkoutPickerDelegate handles input on the workout picker screen.
// Supports scrolling through the workout list and starting a swim session
// with the selected workout.
class WorkoutPickerDelegate extends WatchUi.BehaviorDelegate {
    hidden var _defaultPoolLength = 25;
    hidden var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Select button confirms the highlighted workout and starts a swim.
    function onSelect() {
        var workout = _view.getSelectedWorkout();

        // Track recent usage if a named workout was picked
        if (workout != null && workout["id"] != null) {
            WorkoutCache.setRecent(workout["id"]);
        }

        // Start a swim session with default pool length
        var controller = new SwimController(_defaultPoolLength);
        controller.startSwim();

        var view = new SwimMetricsView(controller.getSession());
        var delegate = new SwimSessionDelegate(controller);
        WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        return true;
    }

    // Scroll down through list items
    function onNextPage() {
        var idx = _view.getSelectedIndex();
        if (idx < _view.getItemCount() - 1) {
            _view.setSelectedIndex(idx + 1);
            WatchUi.requestUpdate();
        }
        return true;
    }

    // Scroll up through list items
    function onPreviousPage() {
        var idx = _view.getSelectedIndex();
        if (idx > 0) {
            _view.setSelectedIndex(idx - 1);
            WatchUi.requestUpdate();
        }
        return true;
    }
}
