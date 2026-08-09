using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Application;

// Splash screen: displays the Swimmy logo and app version for 3 seconds,
// then automatically transitions to the workout picker.
class SplashView extends WatchUi.View {
    private var _timer;
    private var _logo;
    private var _appName;
    private var _appVersion;

    // Vertical gap between the app name and the version label
    private const NAME_VERSION_GAP = 4;
    // Vertical offset to nudge name/version below center
    private const CENTER_OFFSET = 10;

    function initialize() {
        View.initialize();
        _timer = new Timer.Timer();
        _logo = WatchUi.loadResource(Rez.Drawables.LauncherIcon);
        _appName = WatchUi.loadResource(Rez.Strings.AppName);
        _appVersion = WatchUi.loadResource(Rez.Strings.AppVersion);
    }

    function onShow() {
        // Transition to the normal initial view after 3 seconds.
        _timer.start(method(:onSplashDone), 3000, false);
    }

    function onHide() {
        _timer.stop();
    }

    function onSplashDone() {
        var view = new WorkoutPickerView();
        WatchUi.switchToView(view, new WorkoutPickerDelegate(view), WatchUi.SLIDE_IMMEDIATE);
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Dark AMOLED background
        dc.setColor(Theme.BG, Theme.BG);
        dc.clear();

        // Draw the launcher icon (logo) centered in the upper half.
        // Use the bitmap's own dimensions so the position is always correct.
        var logoW = _logo.getWidth();
        var logoH = _logo.getHeight();
        dc.drawBitmap((w - logoW) / 2, h / 4 - logoH / 2, _logo);

        // App name in accent color, below vertical center
        var nameY = h / 2 + CENTER_OFFSET;
        dc.setColor(Theme.ACCENT, Theme.TRANSPARENT);
        dc.drawText(w / 2, nameY, Theme.FONT_TITLE,
            _appName, Graphics.TEXT_JUSTIFY_CENTER);

        // Version number immediately below the name
        // Version is defined in strings.xml and should match the manifest version.
        dc.setColor(Theme.TEXT_SECONDARY, Theme.TRANSPARENT);
        dc.drawText(w / 2, nameY + dc.getFontHeight(Theme.FONT_TITLE) + NAME_VERSION_GAP,
            Theme.FONT_LABEL, _appVersion, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
