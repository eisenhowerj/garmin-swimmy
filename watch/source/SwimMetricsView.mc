using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Lang;

// SwimMetricsView displays the in-swim data screen with:
// - Primary: current pace /100m (largest text)
// - Secondary: lap count, elapsed time, heart rate
// - Optional: stroke count
class SwimMetricsView extends WatchUi.View {
    hidden var _session = null;

    function initialize(session) {
        View.initialize();
        _session = session;
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;

        // Primary metric: pace /100m
        var pace = _session.getPacePer100m();
        var paceStr = _formatPace(pace);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 30, Graphics.FONT_NUMBER_HOT, paceStr,
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 90, Graphics.FONT_TINY, "/100m",
            Graphics.TEXT_JUSTIFY_CENTER);

        // Secondary metrics row
        var y = 130;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Lap count
        dc.drawText(18, y, Graphics.FONT_MEDIUM,
            "Laps: " + _session.getLapCount(),
            Graphics.TEXT_JUSTIFY_LEFT);

        // Elapsed time
        var elapsed = _session.getElapsedSeconds();
        var elapsedStr = _formatTime(elapsed);
        dc.drawText(cx, y + 36, Graphics.FONT_MEDIUM, elapsedStr,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Heart rate
        var hr = _session.getHeartRate();
        var hrStr = hr > 0 ? hr.toString() + " bpm" : "-- bpm";
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(18, y + 72, Graphics.FONT_MEDIUM, hrStr,
            Graphics.TEXT_JUSTIFY_LEFT);

        // Stroke count
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() - 18, y + 72, Graphics.FONT_SMALL,
            "S:" + _session.getStrokeCount(),
            Graphics.TEXT_JUSTIFY_RIGHT);
    }

    hidden function _formatPace(secondsPer100m) {
        if (secondsPer100m == 0) {
            return "--:--";
        }
        var mins = secondsPer100m / 60;
        var secs = secondsPer100m % 60;
        return mins.format("%d") + ":" + secs.format("%02d");
    }

    hidden function _formatTime(totalSeconds) {
        var mins = totalSeconds / 60;
        var secs = totalSeconds % 60;
        return mins.format("%d") + ":" + secs.format("%02d");
    }
}
