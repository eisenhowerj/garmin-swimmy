using Toybox.Graphics;
using Toybox.WatchUi;

// Workout picker: one primary action (select + start), large tap targets,
// minimal information density per screen.
// Shows: Quick Start, recent workout (if any), preset workouts, custom workouts.
class WorkoutPickerView extends WatchUi.View {
    private var _selected = 0;
    private var _items;       // Array of { "label" => String, "workout" => Dict|null }
    private var _scrollOffset = 0;

    function initialize() {
        View.initialize();
        _items = buildItems();
    }

    // Rebuild the picker item list from the workout cache.
    function refresh() {
        _items = buildItems();
        if (_selected >= _items.size()) {
            _selected = _items.size() - 1;
        }
        WatchUi.requestUpdate();
    }

    function getSelectedIndex() {
        return _selected;
    }

    function setSelectedIndex(index) {
        if (index >= 0 && index < _items.size()) {
            _selected = index;
        }
    }

    function getItemCount() {
        return _items.size();
    }

    // Returns the workout dictionary for the currently selected item, or null
    // for Quick Start.
    function getSelectedWorkout() {
        if (_selected >= 0 && _selected < _items.size()) {
            return _items[_selected]["workout"];
        }
        return null;
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Dark AMOLED background
        dc.setColor(Theme.BG, Theme.BG);
        dc.clear();

        // Title – centered, accent color
        dc.setColor(Theme.ACCENT, Theme.TRANSPARENT);
        dc.drawText(w / 2, Theme.MARGIN, Theme.FONT_TITLE, Rez.Strings.SelectWorkout,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Compute how many rows fit below the title
        var listTop = Theme.MARGIN + Theme.ROW_HEIGHT + 8;
        var maxVisible = (h - listTop - Theme.MARGIN) / Theme.ROW_HEIGHT;
        if (maxVisible < 1) { maxVisible = 1; }

        // Adjust scroll so selected item is visible
        if (_selected < _scrollOffset) {
            _scrollOffset = _selected;
        } else if (_selected >= _scrollOffset + maxVisible) {
            _scrollOffset = _selected - maxVisible + 1;
        }

        // Draw visible rows
        var y = listTop;
        for (var i = _scrollOffset; i < _items.size() && i < _scrollOffset + maxVisible; i++) {
            drawRow(dc, y, _items[i]["label"], i == _selected, w);
            y += Theme.ROW_HEIGHT;
        }
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

    // Build the ordered item list: Quick Start, Recent, Presets, Customs.
    private function buildItems() {
        var items = [];

        // Always-available quick start
        items.add({ "label" => Rez.Strings.QuickStart, "workout" => null });

        // Recent workout
        var recent = WorkoutCache.getRecent();
        if (recent != null) {
            items.add({ "label" => "\u25B6 " + recent["name"], "workout" => recent });
        }

        // Preset workouts
        var presets = WorkoutCache.getByKind("preset");
        for (var i = 0; i < presets.size(); i++) {
            items.add({ "label" => presets[i]["name"], "workout" => presets[i] });
        }

        // Custom workouts
        var customs = WorkoutCache.getByKind("custom");
        for (var i = 0; i < customs.size(); i++) {
            items.add({ "label" => customs[i]["name"], "workout" => customs[i] });
        }

        // If no synced workouts exist, show placeholder
        if (presets.size() == 0 && customs.size() == 0 && recent == null) {
            items.add({ "label" => Rez.Strings.NoWorkouts, "workout" => null });
        }

        return items;
    }
}
