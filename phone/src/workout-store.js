const MAX_WORKOUTS = 50;

export class WorkoutStore {
  #storage;
  #key;

  constructor(storage, key = "swimmy.workouts.v1") {
    if (!storage?.getItem || !storage?.setItem) {
      throw new TypeError("storage must implement getItem and setItem");
    }
    this.#storage = storage;
    this.#key = key;
  }

  list() {
    return this.#read().workouts;
  }

  save(workout, now = new Date()) {
    validateWorkout(workout);
    const state = this.#read();
    const existing = state.workouts.findIndex(({ id }) => id === workout.id);
    if (existing === -1 && state.workouts.length === MAX_WORKOUTS) {
      throw new RangeError(`A maximum of ${MAX_WORKOUTS} workouts is supported`);
    }

    const revision = state.revision + 1;
    const saved = structuredClone(workout);
    const workouts = [...state.workouts];
    if (existing === -1) workouts.push(saved);
    else workouts[existing] = saved;
    this.#write({ revision, workouts });
    return envelope("upsert", saved, revision, now);
  }

  remove(id, now = new Date()) {
    const state = this.#read();
    const workout = state.workouts.find((candidate) => candidate.id === id);
    if (!workout) return null;
    const revision = state.revision + 1;
    this.#write({ revision, workouts: state.workouts.filter((candidate) => candidate.id !== id) });
    return envelope("delete", { id: workout.id }, revision, now);
  }

  #read() {
    const raw = this.#storage.getItem(this.#key);
    if (raw === null) return { revision: 0, workouts: [] };
    let state;
    try {
      state = JSON.parse(raw);
    } catch {
      throw new TypeError("Stored workout data is invalid");
    }
    if (!Number.isInteger(state.revision) || state.revision < 1 || !Array.isArray(state.workouts)) {
      throw new TypeError("Stored workout data is invalid");
    }
    state.workouts.forEach(validateWorkout);
    return state;
  }

  #write(state) {
    this.#storage.setItem(this.#key, JSON.stringify(state));
  }
}

export function validateWorkout(workout) {
  const allowedFields = new Set(["schemaVersion", "id", "kind", "name", "blocks"]);
  if (!workout || typeof workout !== "object" || Array.isArray(workout)) {
    throw new TypeError("Workout does not satisfy workout-v1");
  }
  if (Object.keys(workout).some((field) => !allowedFields.has(field))) {
    throw new TypeError("Workout contains unsupported fields");
  }
  if (workout.schemaVersion !== 1 ||
      !/^[A-Za-z0-9_-]{1,64}$/.test(workout.id) ||
      !["preset", "custom"].includes(workout.kind) ||
      typeof workout.name !== "string" || workout.name.length < 1 || workout.name.length > 48 ||
      !Array.isArray(workout.blocks) || workout.blocks.length < 1 || workout.blocks.length > 32) {
    throw new TypeError("Workout does not satisfy workout-v1");
  }
  workout.blocks.forEach((block) => {
    if (!block || typeof block !== "object" || Array.isArray(block)) {
      throw new TypeError("Workout block does not satisfy workout-v1");
    }
    const allowedBlockFields = new Set(["distanceMeters", "repetitions", "restSeconds"]);
    if (Object.keys(block).some((field) => !allowedBlockFields.has(field))) {
      throw new TypeError("Workout block contains unsupported fields");
    }
    if (!Number.isInteger(block.distanceMeters) || block.distanceMeters < 1 ||
        block.distanceMeters > 10000 || !Number.isInteger(block.repetitions) ||
        block.repetitions < 1 || block.repetitions > 100 ||
        !Number.isInteger(block.restSeconds) || block.restSeconds < 0 || block.restSeconds > 3600) {
      throw new TypeError("Workout block does not satisfy workout-v1");
    }
  });
}

function envelope(operation, workout, revision, now) {
  return {
    schemaVersion: 1,
    revision,
    updatedAt: now.toISOString(),
    operation,
    workout: structuredClone(workout)
  };
}
