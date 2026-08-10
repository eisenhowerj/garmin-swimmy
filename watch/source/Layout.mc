using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;

// Layout helpers for circular AMOLED displays.
module Layout {
    // Returns half-width available at the given y coordinate inside the circular safe radius.
    function halfWidthAtY(dc, y) {
        var radius = Theme.SAFE_RADIUS;
        var dy = y - (dc.getHeight() / 2);
        if (dy < 0) { dy = -dy; }
        if (dy >= radius) {
            return Theme.MIN_HALF_WIDTH;
        }
        var spanSq = (radius * radius) - (dy * dy);
        var span = Math.sqrt(spanSq);
        var half = span - Theme.SAFE_MARGIN;
        if (half < Theme.MIN_HALF_WIDTH) {
            return Theme.MIN_HALF_WIDTH;
        }
        return half;
    }

    function leftAtY(dc, y) {
        return (dc.getWidth() / 2) - halfWidthAtY(dc, y);
    }

    function rightAtY(dc, y) {
        return (dc.getWidth() / 2) + halfWidthAtY(dc, y);
    }

    function safeTop(dc) {
        return (dc.getHeight() / 2) - Theme.SAFE_RADIUS + Theme.SAFE_MARGIN;
    }

    function safeBottom(dc) {
        return (dc.getHeight() / 2) + Theme.SAFE_RADIUS - Theme.SAFE_MARGIN;
    }

    // Draws centered text and falls back through fonts if the text is too wide.
    function drawCenteredTextFitted(dc, y, fonts, text, color) {
        var width = rightAtY(dc, y) - leftAtY(dc, y);
        var fitted = fitText(dc, fonts, text, width) as Lang.Dictionary;
        dc.setColor(color, Theme.TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, y, fitted.get("font"), fitted.get("text"), Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Draws left-aligned text in a bounded row and applies font fallback + truncation.
    function drawLeftTextFitted(dc, x, y, maxWidth, fonts, text, color) {
        var fitted = fitText(dc, fonts, text, maxWidth) as Lang.Dictionary;
        dc.setColor(color, Theme.TRANSPARENT);
        dc.drawText(x, y, fitted.get("font"), fitted.get("text"), Graphics.TEXT_JUSTIFY_LEFT);
    }

    function fitText(dc, fonts, text, maxWidth) {
        var fontArray = fonts as Lang.Array;
        var useText = text;
        for (var i = 0; i < fontArray.size(); i++) {
            var font = fontArray[i];
            if (dc.getTextWidthInPixels(useText, font) <= maxWidth) {
                var result = {} as Lang.Dictionary;
                result["font"] = font;
                result["text"] = useText;
                return result;
            }
        }
        var fallback = fontArray[fontArray.size() - 1];
        var result = {} as Lang.Dictionary;
        result["font"] = fallback;
        result["text"] = ellipsize(dc, useText, fallback, maxWidth);
        return result;
    }

    function ellipsize(dc, text, font, maxWidth) {
        if (dc.getTextWidthInPixels(text, font) <= maxWidth) {
            return text;
        }
        var dots = "...";
        if (dc.getTextWidthInPixels(dots, font) > maxWidth) {
            return "";
        }
        var end = text.length();
        while (end > 0) {
            var candidate = text.substring(0, end) + dots;
            if (dc.getTextWidthInPixels(candidate, font) <= maxWidth) {
                return candidate;
            }
            end -= 1;
        }
        return dots;
    }
}
