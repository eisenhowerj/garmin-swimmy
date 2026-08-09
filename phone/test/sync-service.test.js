import assert from "node:assert/strict";
import test from "node:test";
import { WorkoutStore } from "../src/workout-store.js";
import { SyncService } from "../src/sync-service.js";

class MemoryStorage {
  values = new Map();
  getItem(key) { return this.values.get(key) ?? null; }
  setItem(key, value) { this.values.set(key, value); }
}

const workout = {
  schemaVersion: 1,
  id: "intervals-10x100",
  kind: "preset",
  name: "10x100m Intervals",
  blocks: [{ distanceMeters: 100, repetitions: 10, restSeconds: 30 }]
};

const customWorkout = {
  schemaVersion: 1,
  id: "coach-tuesday",
  kind: "custom",
  name: "Coach Tuesday Set",
  blocks: [
    { distanceMeters: 200, repetitions: 4, restSeconds: 20 },
    { distanceMeters: 50, repetitions: 8, restSeconds: 10 }
  ]
};

test("saveWorkout enqueues an upsert envelope", () => {
  const store = new WorkoutStore(new MemoryStorage());
  const sync = new SyncService(store);

  const envelope = sync.saveWorkout(workout);
  assert.equal(envelope.operation, "upsert");
  assert.equal(envelope.revision, 1);
  assert.equal(sync.getPendingCount(), 1);
});

test("removeWorkout enqueues a delete envelope", () => {
  const store = new WorkoutStore(new MemoryStorage());
  const sync = new SyncService(store);
  sync.saveWorkout(workout);

  const envelope = sync.removeWorkout(workout.id);
  assert.equal(envelope.operation, "delete");
  assert.equal(envelope.revision, 2);
  assert.equal(sync.getPendingCount(), 2);
});

test("removeWorkout for unknown id returns null and does not enqueue", () => {
  const store = new WorkoutStore(new MemoryStorage());
  const sync = new SyncService(store);

  assert.equal(sync.removeWorkout("nonexistent"), null);
  assert.equal(sync.getPendingCount(), 0);
});

test("acknowledge clears envelopes up to revision", () => {
  const store = new WorkoutStore(new MemoryStorage());
  const sync = new SyncService(store);
  sync.saveWorkout(workout);
  sync.saveWorkout(customWorkout);

  sync.acknowledge(1);
  assert.equal(sync.getPendingCount(), 1);
  assert.equal(sync.getLastAckedRevision(), 1);

  const pending = sync.getPendingEnvelopes();
  assert.equal(pending[0].revision, 2);
});

test("acknowledge rejects invalid revision", () => {
  const store = new WorkoutStore(new MemoryStorage());
  const sync = new SyncService(store);

  assert.throws(() => sync.acknowledge(0), /revision must be a positive integer/);
  assert.throws(() => sync.acknowledge(-1), /revision must be a positive integer/);
  assert.throws(() => sync.acknowledge(1.5), /revision must be a positive integer/);
});

test("getPendingEnvelopes returns ordered envelopes", () => {
  const store = new WorkoutStore(new MemoryStorage());
  const sync = new SyncService(store);
  sync.saveWorkout(workout);
  sync.saveWorkout(customWorkout);

  const pending = sync.getPendingEnvelopes();
  assert.equal(pending.length, 2);
  assert.equal(pending[0].revision, 1);
  assert.equal(pending[1].revision, 2);
});

test("listWorkouts delegates to the store", () => {
  const store = new WorkoutStore(new MemoryStorage());
  const sync = new SyncService(store);
  sync.saveWorkout(workout);

  assert.deepEqual(sync.listWorkouts(), [workout]);
});

test("constructor rejects non-WorkoutStore", () => {
  assert.throws(() => new SyncService({}), /store must be a WorkoutStore instance/);
});
