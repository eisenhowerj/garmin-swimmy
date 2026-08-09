using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;

// Milestone overlay: single message, auto-dismiss, one primary action (acknowledge).
class MilestoneView extends WatchUi.View {
    private var _message = "";
    private var _timer;
    private var _dismissed = false;
    private var _milestoneLabel;
    private var _tapDismissLabel;

    function initialize(message) {
        View.initialize();
        _message = message;
        _timer = new Timer.Timer();
        _milestoneLabel = WatchUi.loadResource(Rez.Strings.Milestone);
        _tapDismissLabel = WatchUi.loadResource(Rez.Strings.TapDismiss);
        // Auto-dismiss after 3 seconds
        _timer.start(method(:dismiss), 3000, false);
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Semi-transparent dark overlay
        dc.setColor(Theme.BG, Theme.BG);
        dc.clear();

        // Accent badge area
        var badgeY = h / 2 - 40;
        dc.setColor(Theme.SUCCESS, Theme.TRANSPARENT);
        dc.drawText(w / 2, badgeY - 40, Theme.FONT_TITLE, _milestoneLabel,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Milestone detail
        dc.setColor(Theme.TEXT_PRIMARY, Theme.TRANSPARENT);
        dc.drawText(w / 2, badgeY + 20, Theme.FONT_SECONDARY, _message,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Dismiss hint
        dc.setColor(Theme.TEXT_SECONDARY, Theme.TRANSPARENT);
        dc.drawText(w / 2, h - Theme.MARGIN - 24, Theme.FONT_LABEL, _tapDismissLabel,
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function dismiss() as Void {
        if (_dismissed) { return; }
        _dismissed = true;
        _timer.stop();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
