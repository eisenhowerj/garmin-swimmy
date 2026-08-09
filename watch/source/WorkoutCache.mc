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
        var all = getWorkouts();
        var result = [];
        for (var i = 0; i < all.size(); i++) {
            if (all[i]["kind"] != null && all[i]["kind"].equals(kind)) {
                result.add(all[i]);
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
        var all = getWorkouts();
        for (var i = 0; i < all.size(); i++) {
            if (all[i]["id"] != null && all[i]["id"].equals(recentId)) {
                return all[i];
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
        var incomingRev = envelope["revision"];
        if (incomingRev == null || incomingRev <= getRevision()) {
            return;
        }

        var operation = envelope["operation"];
        var workout = envelope["workout"];
        var all = getWorkouts();

        if (operation != null && operation.equals("upsert") && workout != null) {
            var found = false;
            for (var i = 0; i < all.size(); i++) {
                if (all[i]["id"] != null && all[i]["id"].equals(workout["id"])) {
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
                if (all[i]["id"] == null || !all[i]["id"].equals(workout["id"])) {
                    filtered.add(all[i]);
                }
            }
            all = filtered;
        }

        Application.Storage.setValue(STORAGE_KEY, all);
        Application.Storage.setValue(REVISION_KEY, incomingRev);
    }
}
