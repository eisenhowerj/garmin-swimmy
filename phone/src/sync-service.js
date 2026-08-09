import { WorkoutStore } from "./workout-store.js";

/**
 * SyncService manages the queue of sync envelopes destined for the watch.
 * It wraps a WorkoutStore and accumulates pending changes that the transport
 * layer (BLE / Communications API) can drain and send to the watch.
 */
export class SyncService {
  #store;
  #queue; // Array of sync envelopes pending delivery
  #lastAckedRevision;

  constructor(store) {
    if (!(store instanceof WorkoutStore)) {
      throw new TypeError("store must be a WorkoutStore instance");
    }
    this.#store = store;
    this.#queue = [];
    this.#lastAckedRevision = 0;
  }

  /** Save (upsert) a workout and enqueue the resulting envelope for sync. */
  saveWorkout(workout, now = new Date()) {
    const envelope = this.#store.save(workout, now);
    this.#queue.push(envelope);
    return envelope;
  }

  /** Remove a workout and enqueue the resulting delete envelope for sync. */
  removeWorkout(id, now = new Date()) {
    const envelope = this.#store.remove(id, now);
    if (envelope) {
      this.#queue.push(envelope);
    }
    return envelope;
  }

  /** Returns all envelopes not yet acknowledged by the watch. */
  getPendingEnvelopes() {
    return this.#queue.filter((e) => e.revision > this.#lastAckedRevision);
  }

  /** Returns the count of pending envelopes. */
  getPendingCount() {
    return this.getPendingEnvelopes().length;
  }

  /**
   * Acknowledge that the watch has received all envelopes up to and
   * including the given revision. Removes acknowledged items from the queue.
   */
  acknowledge(revision) {
    if (!Number.isInteger(revision) || revision < 1) {
      throw new RangeError("revision must be a positive integer");
    }
    this.#lastAckedRevision = revision;
    this.#queue = this.#queue.filter((e) => e.revision > revision);
  }

  /** Returns the last acknowledged revision. */
  getLastAckedRevision() {
    return this.#lastAckedRevision;
  }

  /** Returns all workouts from the underlying store. */
  listWorkouts() {
    return this.#store.list();
  }
}
