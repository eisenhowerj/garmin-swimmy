using Toybox.Application;

class SwimmyApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [new WorkoutPickerView()];
    }
}
