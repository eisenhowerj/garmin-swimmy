using Toybox.Graphics;
using Toybox.WatchUi;

// In-swim data screen: one primary metric dominates, minimal clutter.
class InSwimView extends WatchUi.View {
    // Placeholders – will be populated by swim session data
    private var _pace = "--:--";
    private var _laps = 0;
    private var _elapsed = "0:00";
    private var _hr = "--";
    private var _setProgress = "";
    private var _paceLabel;
    private var _lapsLabel;
    private var _bpmLabel;

    function initialize() {
        View.initialize();
        _paceLabel = WatchUi.loadResource(Rez.Strings.PaceLabel);
        _lapsLabel = WatchUi.loadResource(Rez.Strings.Laps);
        _bpmLabel = WatchUi.loadResource(Rez.Strings.Bpm);
    }

    function setPace(pace) { _pace = pace; }
    function setLaps(laps) { _laps = laps; }
    function setElapsed(elapsed) { _elapsed = elapsed; }
    function setHeartRate(hr) { _hr = hr; }
    function updateSetProgress(progress) { _setProgress = progress; }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Dark background
        dc.setColor(Theme.BG, Theme.BG);
        dc.clear();

        // Primary metric: pace (largest text, center)
        dc.setColor(Theme.TEXT_PRIMARY, Theme.TRANSPARENT);
        dc.drawText(w / 2, h / 2 - 50, Theme.FONT_PRIMARY, _pace,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Label above primary metric
        dc.setColor(Theme.TEXT_SECONDARY, Theme.TRANSPARENT);
        dc.drawText(w / 2, h / 2 - 90, Theme.FONT_LABEL, _paceLabel,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Secondary metrics row below
        var metricsY = h / 2 + 40;
        dc.setColor(Theme.TEXT_SECONDARY, Theme.TRANSPARENT);
        dc.drawText(w / 4, metricsY, Theme.FONT_LABEL, _laps.toString() + " " + _lapsLabel,
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w / 2, metricsY, Theme.FONT_LABEL, _elapsed,
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(3 * w / 4, metricsY, Theme.FONT_LABEL, _hr + " " + _bpmLabel,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Optional set progress (compact, bottom)
        if (!_setProgress.equals("")) {
            dc.setColor(Theme.ACCENT, Theme.TRANSPARENT);
            dc.drawText(w / 2, h - Theme.MARGIN - 24, Theme.FONT_LABEL, _setProgress,
                Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
