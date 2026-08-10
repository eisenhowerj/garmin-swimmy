using Toybox.Graphics;

// Material-inspired AMOLED theme: high contrast, readability-first.
module Theme {
    // Background – pure black for AMOLED power efficiency
    const BG = Graphics.COLOR_BLACK;

    // Primary text – bright white for maximum contrast
    const TEXT_PRIMARY = Graphics.COLOR_WHITE;

    // Secondary text – muted for less critical info
    const TEXT_SECONDARY = Graphics.COLOR_LT_GRAY;

    // Accent – vivid cyan for interactive/highlight elements
    const ACCENT = 0x00E5FF;

    // Success/milestone – bright green
    const SUCCESS = 0x00E676;

    // Warning – amber
    const WARNING = 0xFFD600;

    // Transparent for text backgrounds
    const TRANSPARENT = Graphics.COLOR_TRANSPARENT;

    // Typography helpers (Connect IQ font enums)
    const FONT_TITLE = Graphics.FONT_LARGE;
    const FONT_PRIMARY = Graphics.FONT_NUMBER_HOT;
    const FONT_SECONDARY = Graphics.FONT_MEDIUM;
    const FONT_LABEL = Graphics.FONT_SMALL;

    // Layout constants for 416×416 circular AMOLED target (47mm class)
    const MARGIN = 18;
    const ROW_HEIGHT = 56;
    const SAFE_RADIUS = 192;
    const SAFE_MARGIN = 14;
    const MIN_HALF_WIDTH = 70;

    // Font fallback stacks for constrained circular regions.
    const TITLE_FONTS = [Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL];
    const BODY_FONTS = [Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY];
    const METRIC_FONTS = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM];
}
