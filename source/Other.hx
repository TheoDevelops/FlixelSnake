import flixel.util.FlxColor;

class Other
{
    public static var keyHSV = [
        {hue: 0,      saturation: 1, value: 1}, // red
        {hue: 30,     saturation: 1, value: 1}, // orange
        {hue: 60,     saturation: 1, value: 1}, // yellow
        {hue: 120,    saturation: 1, value: 1}, // green
        {hue: 180,    saturation: 1, value: 1}, // cyan
        {hue: 240,    saturation: 1, value: 1}, // blue
        {hue: 270,    saturation: 1, value: 1}, // dark purple ???
        {hue: 300,    saturation: 1, value: 1} // purple
    ];
    // loosely based on a stack overflow post lol
    public static function generateRainbowColors(divs:Int):Array<Int>
    {
        var colors:Array<FlxColor> = [];
        
        for (i in 0...divs)
        {
            var t:Float = i / (divs - 1);
            var color1Index = Std.int(t * (keyHSV.length - 1));
            var color2Index = Std.int(Math.min(color1Index + 1, keyHSV.length - 1));
            var factor:Float = t * (keyHSV.length - 1) - color1Index;
            
            var color1HSV = keyHSV[color1Index];
            var color2HSV = keyHSV[color2Index];
            
            var hue = color1HSV.hue + factor * (color2HSV.hue - color1HSV.hue);
            var saturation = color1HSV.saturation + factor * (color2HSV.saturation - color1HSV.saturation);
            var value = color1HSV.value + factor * (color2HSV.value - color1HSV.value);
    
            var rgb:FlxColor = FlxColor.fromHSB(hue, saturation, value);
            colors.push(rgb);
        }
        
        return colors;
    }
}