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
        // Dark background
        dc.setColor(Theme.BG, Theme.BG);
        dc.clear();

        var safeTop = Layout.safeTop(dc);
        var safeBottom = Layout.safeBottom(dc);
        var safeCenter = (safeTop + safeBottom) / 2;

        // Milestone label at upper-center safe zone
        var labelY = safeTop + 30;
        Layout.drawCenteredTextFitted(dc, labelY, Theme.TITLE_FONTS, _milestoneLabel, Theme.SUCCESS);

        // Milestone message detail at center, with text fitting
        var messageY = safeCenter;
        Layout.drawCenteredTextFitted(dc, messageY, Theme.BODY_FONTS, _message, Theme.TEXT_PRIMARY);

        // Dismiss hint at lower-center safe zone
        var hintY = safeBottom - 40;
        Layout.drawCenteredTextFitted(dc, hintY, Theme.BODY_FONTS, _tapDismissLabel, Theme.TEXT_SECONDARY);
    }

    function dismiss() as Void {
        if (_dismissed) { return; }
        _dismissed = true;
        _timer.stop();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
