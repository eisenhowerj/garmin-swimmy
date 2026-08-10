using Toybox.Graphics;
using Toybox.WatchUi;

// SwimMetricsView displays the in-swim data screen with:
// - Current lap time (mm:ss)
// - Last lap duration (mm:ss)
// - Heart rate
class SwimMetricsView extends WatchUi.View {
    hidden var _session = null;

    function initialize(session) {
        View.initialize();
        _session = session;
    }

    function onUpdate(dc) {
        dc.setColor(Theme.BG, Theme.BG);
        dc.clear();

        var safeTop = Layout.safeTop(dc);
        var safeBottom = Layout.safeBottom(dc);
        var cx = dc.getWidth() / 2;

        var mainTimer = _formatTime(_session.getCurrentLapSeconds());
        var mainY = safeTop + 46;
        Layout.drawCenteredTextFitted(dc, mainY, Theme.METRIC_FONTS, mainTimer, Theme.TEXT_PRIMARY);

        var lastLap = _session.getLastLapSeconds();
        var lastLapStr = lastLap == null ? "--:--" : _formatTime(lastLap);
        var secondaryY = safeBottom - 74;
        dc.setColor(Theme.TEXT_SECONDARY, Theme.TRANSPARENT);
        dc.drawText(cx - 10, secondaryY, Graphics.FONT_SMALL, lastLapStr, Graphics.TEXT_JUSTIFY_RIGHT);

        var hr = _session.getHeartRate();
        var hrStr = hr > 0 ? hr.toString() + " bpm" : "-- bpm";
        dc.drawText(cx + 10, secondaryY, Graphics.FONT_TINY, hrStr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    hidden function _formatTime(totalSeconds) {
        var mins = totalSeconds / 60;
        var secs = totalSeconds % 60;
        return mins.format("%d") + ":" + secs.format("%02d");
    }

}
