using Toybox.WatchUi;

// MilestoneDetector evaluates swim session state after each lap or tick
// and fires haptic + visual feedback when a milestone condition is met.
//
// Milestone types:
//   - Lap count milestones (every 5 laps, plus 1st lap)
//   - Target distance reached (total workout distance from blocks)
//   - Workout block completion (cumulative reps×distance boundaries)
//   - Personal best split (fastest single-lap pace)
class MilestoneDetector {
    // Lap counts that trigger a milestone
    hidden const LAP_INTERVAL = 5;

    hidden var _lastCheckedLap = 0;
    hidden var _targetDistanceMeters = 0;
    hidden var _targetDistanceReached = false;
    hidden var _blockBoundaries = null; // array of cumulative distances
    hidden var _nextBlockIdx = 0;
    hidden var _bestLapMs = 0; // best single-lap time in ms (lower is better)
    hidden var _lapStartMs = 0;
    hidden var _poolLengthMeters = 25;

    // Initialize with workout info (may be null for quick-start)
    function initialize(workout, poolLengthMeters) {
        _poolLengthMeters = poolLengthMeters;
        _blockBoundaries = [];
        _targetDistanceMeters = 0;

        if (workout != null && workout.hasKey("blocks")) {
            var cumulative = 0;
            var blocks = workout["blocks"];
            for (var i = 0; i < blocks.size(); i++) {
                var block = blocks[i];
                cumulative += block["distanceMeters"] * block["repetitions"];
                _blockBoundaries.add(cumulative);
            }
            _targetDistanceMeters = cumulative;
        }
    }

    // Called when the session starts to init lap timing
    function onSessionStart(nowMs) {
        _lapStartMs = nowMs;
        _bestLapMs = 0;
    }

    // Called when a lap is recorded. Returns true if any milestone triggered.
    function onLapRecorded(session, nowMs) {
        var lapCount = session.getLapCount();
        var distance = session.getTotalDistanceMeters();
        var message = null;

        // --- Personal best split detection (highest priority) ---
        if (_lapStartMs > 0) {
            var lapTime = nowMs - _lapStartMs;
            if (lapTime > 0 && (_bestLapMs == 0 || lapTime < _bestLapMs)) {
                // Only fire PB after the first lap (need a baseline)
                if (_bestLapMs > 0) {
                    HapticManager.pulsePersonalBest();
                    message = "New best split!";
                }
                _bestLapMs = lapTime;
            }
        }
        _lapStartMs = nowMs;

        // --- Block completion ---
        if (message == null && _blockBoundaries != null) {
            while (_nextBlockIdx < _blockBoundaries.size() && distance >= _blockBoundaries[_nextBlockIdx]) {
                _nextBlockIdx += 1;
            }
            if (_nextBlockIdx > 0 && _nextBlockIdx > _lastCheckedBlockIdx()) {
                HapticManager.pulseBlockComplete();
                message = "Block " + _nextBlockIdx + " complete";
            }
        }

        // --- Target distance reached ---
        if (message == null && _targetDistanceMeters > 0 && !_targetDistanceReached && distance >= _targetDistanceMeters) {
            _targetDistanceReached = true;
            HapticManager.pulseDistance();
            message = distance + "m target reached!";
        }

        // --- Lap count milestones ---
        if (message == null && (lapCount == 1 || (lapCount % LAP_INTERVAL == 0 && lapCount > _lastCheckedLap))) {
            HapticManager.pulseLap();
            message = "Lap " + lapCount;
        }
        _lastCheckedLap = lapCount;

        if (message != null) {
            _showMilestone(message);
            return true;
        }
        return false;
    }

    hidden var _prevBlockIdx = 0;
    hidden function _lastCheckedBlockIdx() {
        var v = _prevBlockIdx;
        _prevBlockIdx = _nextBlockIdx;
        return v;
    }

    hidden function _showMilestone(message) {
        WatchUi.pushView(new MilestoneView(message), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_UP);
    }
}
