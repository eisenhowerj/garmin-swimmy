using Toybox.Graphics;
using Toybox.WatchUi;

class WorkoutPickerView extends WatchUi.View {
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 24, Graphics.FONT_LARGE, Rez.Strings.SelectWorkout,
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(18, 76, Graphics.FONT_MEDIUM, Rez.Strings.QuickStart,
            Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(18, 116, Graphics.FONT_MEDIUM, Rez.Strings.NoWorkouts,
            Graphics.TEXT_JUSTIFY_LEFT);
    }
}
