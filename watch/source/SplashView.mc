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

        // Dark AMOLED background
        dc.setColor(Theme.BG, Theme.BG);
        dc.clear();

        var safeTop = Layout.safeTop(dc);
        var safeBottom = Layout.safeBottom(dc);

        // Draw the launcher icon centered above text in circular-safe area.
        var logoW = _logo.getWidth();
        var logoH = _logo.getHeight();
        var logoY = safeTop + 30;
        dc.drawBitmap((w - logoW) / 2, logoY, _logo);

        // App name in accent color, centered with fallback font sizing.
        var nameY = logoY + logoH + 18;
        Layout.drawCenteredTextFitted(dc, nameY, Theme.TITLE_FONTS, _appName, Theme.ACCENT);

        // Version number below the app name, kept within circular-safe bounds.
        var versionY = nameY + 34 + 4;
        if (versionY > safeBottom - 30) {
            versionY = safeBottom - 30;
        }
        Layout.drawCenteredTextFitted(dc, versionY, Theme.BODY_FONTS, _appVersion, Theme.TEXT_SECONDARY);
    }
}
