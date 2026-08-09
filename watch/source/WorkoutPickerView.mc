using Toybox.Graphics;
using Toybox.WatchUi;

// Workout picker: one primary action (select + start), large tap targets,
// minimal information density per screen.
class WorkoutPickerView extends WatchUi.View {
    private var _selected = 0;

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        var w = dc.getWidth();

        // Dark AMOLED background
        dc.setColor(Theme.BG, Theme.BG);
        dc.clear();

        // Title – centered, accent color
        dc.setColor(Theme.ACCENT, Theme.TRANSPARENT);
        dc.drawText(w / 2, Theme.MARGIN, Theme.FONT_TITLE, Rez.Strings.SelectWorkout,
            Graphics.TEXT_JUSTIFY_CENTER);

        // List items – large rows, high contrast
        var y = Theme.MARGIN + Theme.ROW_HEIGHT + 8;

        drawRow(dc, y, Rez.Strings.QuickStart, _selected == 0, w);
        y += Theme.ROW_HEIGHT;
        drawRow(dc, y, Rez.Strings.NoWorkouts, _selected == 1, w);
    }

    private function drawRow(dc, y, label, selected, width) {
        if (selected) {
            // Highlight bar for selected row
            dc.setColor(Theme.ACCENT, Theme.TRANSPARENT);
            dc.fillRoundedRectangle(Theme.MARGIN - 4, y - 4,
                width - (Theme.MARGIN - 4) * 2, Theme.ROW_HEIGHT - 8, 8);
            dc.setColor(Theme.BG, Theme.TRANSPARENT);
        } else {
            dc.setColor(Theme.TEXT_PRIMARY, Theme.TRANSPARENT);
        }
        dc.drawText(Theme.MARGIN + 8, y + 4, Theme.FONT_SECONDARY, label,
            Graphics.TEXT_JUSTIFY_LEFT);
    }
}
