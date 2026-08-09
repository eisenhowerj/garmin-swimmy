using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;

// Milestone overlay: single message, auto-dismiss, one primary action (acknowledge).
class MilestoneView extends WatchUi.View {
    private var _message = "";
    private var _timer;
    private var _dismissed = false;

    function initialize(message) {
        View.initialize();
        _message = message;
        _timer = new Timer.Timer();
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
        dc.drawText(w / 2, badgeY - 40, Theme.FONT_TITLE, Rez.Strings.Milestone,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Milestone detail
        dc.setColor(Theme.TEXT_PRIMARY, Theme.TRANSPARENT);
        dc.drawText(w / 2, badgeY + 20, Theme.FONT_SECONDARY, _message,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Dismiss hint
        dc.setColor(Theme.TEXT_SECONDARY, Theme.TRANSPARENT);
        dc.drawText(w / 2, h - Theme.MARGIN - 24, Theme.FONT_LABEL, Rez.Strings.TapDismiss,
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function dismiss() {
        if (_dismissed) { return; }
        _dismissed = true;
        _timer.stop();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
