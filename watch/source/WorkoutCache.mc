using Toybox.Application;
using Toybox.Lang;

// WorkoutCache persists synced workouts and the most-recently-used workout ID
// in Application.Storage so they survive app restarts.
class WorkoutCache {
    private static const STORAGE_KEY = "workouts";
    private static const RECENT_KEY = "recentId";
    private static const REVISION_KEY = "revision";

    // Returns the array of workout dictionaries from storage.
    static function getWorkouts() {
        var data = Application.Storage.getValue(STORAGE_KEY);
        if (data == null || !(data instanceof Lang.Array)) {
            return [];
        }
        return data;
    }

    // Returns workouts filtered by kind ("preset" or "custom").
    static function getByKind(kind) {
        var all = getWorkouts() as Lang.Array;
        var result = [];
        for (var i = 0; i < all.size(); i++) {
            var workout = all[i] as Lang.Dictionary;
            if (workout["kind"] != null && workout["kind"].equals(kind)) {
                result.add(workout);
            }
        }
        return result;
    }

    // Returns the most recently used workout dictionary, or null.
    static function getRecent() {
        var recentId = Application.Storage.getValue(RECENT_KEY);
        if (recentId == null) {
            return null;
        }
        var all = getWorkouts() as Lang.Array;
        for (var i = 0; i < all.size(); i++) {
            var workout = all[i] as Lang.Dictionary;
            if (workout["id"] != null && workout["id"].equals(recentId)) {
                return workout;
            }
        }
        return null;
    }

    // Marks a workout id as most recently used.
    static function setRecent(id) {
        Application.Storage.setValue(RECENT_KEY, id);
    }

    // Returns the current sync revision (integer), or 0 if unset.
    static function getRevision() {
        var rev = Application.Storage.getValue(REVISION_KEY);
        if (rev == null) {
            return 0;
        }
        return rev;
    }

    // Applies an incoming sync envelope (dictionary with "operation",
    // "revision", and "workout" keys). Ignores stale revisions.
    static function applySyncEnvelope(envelope) {
        var syncEnvelope = envelope as Lang.Dictionary;
        var incomingRev = syncEnvelope["revision"];
        if (incomingRev == null || incomingRev <= getRevision()) {
            return;
        }

        var operation = syncEnvelope["operation"];
        var workout = syncEnvelope["workout"] as Lang.Dictionary;
        var all = getWorkouts() as Lang.Array;

        if (operation != null && operation.equals("upsert") && workout != null) {
            var found = false;
            for (var i = 0; i < all.size(); i++) {
                var existing = all[i] as Lang.Dictionary;
                if (existing["id"] != null && existing["id"].equals(workout["id"])) {
                    all[i] = workout;
                    found = true;
                    break;
                }
            }
            if (!found) {
                all.add(workout);
            }
        } else if (operation != null && operation.equals("delete") && workout != null) {
            var filtered = [];
            for (var i = 0; i < all.size(); i++) {
                var existing = all[i] as Lang.Dictionary;
                if (existing["id"] == null || !existing["id"].equals(workout["id"])) {
                    filtered.add(existing);
                }
            }
            all = filtered;
        }

        Application.Storage.setValue(STORAGE_KEY, all);
        Application.Storage.setValue(REVISION_KEY, incomingRev);
    }
}
