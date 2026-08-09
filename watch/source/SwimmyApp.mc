using Toybox.Application;

class SwimmyApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        var view = new WorkoutPickerView();
        return [view, new WorkoutPickerDelegate(view)];
    }
}
