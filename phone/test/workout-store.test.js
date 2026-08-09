import assert from "node:assert/strict";
import test from "node:test";
import { WorkoutStore } from "../src/workout-store.js";

class MemoryStorage {
  values = new Map();
  getItem(key) { return this.values.get(key) ?? null; }
  setItem(key, value) { this.values.set(key, value); }
}

const workout = {
  schemaVersion: 1,
  id: "endurance-1500",
  kind: "preset",
  name: "1500m Endurance",
  blocks: [{ distanceMeters: 1500, repetitions: 1, restSeconds: 0 }]
};

test("saves a validated workout and returns an upsert envelope", () => {
  const store = new WorkoutStore(new MemoryStorage());
  const change = store.save(workout, new Date("2026-01-01T00:00:00.000Z"));

  assert.equal(change.revision, 1);
  assert.equal(change.operation, "upsert");
  assert.deepEqual(store.list(), [workout]);
});

test("removing a workout creates a delete envelope", () => {
  const store = new WorkoutStore(new MemoryStorage());
  store.save(workout);

  assert.equal(store.remove(workout.id).operation, "delete");
  assert.deepEqual(store.list(), []);
});

test("removing an unknown workout returns null", () => {
  const store = new WorkoutStore(new MemoryStorage());

  assert.equal(store.remove("unknown"), null);
});

test("rejects unsupported fields", () => {
  const store = new WorkoutStore(new MemoryStorage());
  assert.throws(() => store.save({ ...workout, unknown: true }), /unsupported fields/);
});
