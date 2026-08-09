using Toybox.Attention;

// HapticManager provides short, distinct vibration patterns for swim milestones.
// Patterns are intentionally brief to avoid distracting the swimmer.
module HapticManager {
    // Single short pulse – lap milestone
    function pulseLap() {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(50, 200)]);
        }
    }

    // Double short pulse – target distance reached
    function pulseDistance() {
        if (Attention has :vibrate) {
            Attention.vibrate([
                new Attention.VibeProfile(50, 150),
                new Attention.VibeProfile(0, 100),
                new Attention.VibeProfile(50, 150)
            ]);
        }
    }

    // Triple short pulse – workout block complete
    function pulseBlockComplete() {
        if (Attention has :vibrate) {
            Attention.vibrate([
                new Attention.VibeProfile(40, 120),
                new Attention.VibeProfile(0, 80),
                new Attention.VibeProfile(40, 120),
                new Attention.VibeProfile(0, 80),
                new Attention.VibeProfile(40, 120)
            ]);
        }
    }

    // Strong single buzz – personal best split
    function pulsePersonalBest() {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, 300)]);
        }
    }
}
