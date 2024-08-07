package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import openfl.geom.Rectangle;

/**
 * Worst way to do snake (to much loops lol)
 * well... fist time i coded snake on flixel was 606 line... so i guess 301 is good ???
 */
class Snake extends FlxState
{
	var snake:Array<FlxPoint> = [];
	var apple:FlxPoint = FlxPoint.get(Std.int(PTW_AMOUNT / 2), Std.int(PTH_AMOUNT / 2));
	var xDir:Int = 1;
	var yDir:Int = 0;

	public static var tileWidth:Int = Std.int(640 / 24);
	public static var tileHeight:Int = Std.int(480 / 16);

	public static var PTW_AMOUNT = Std.int(640 / tileWidth);
	public static var PTH_AMOUNT = Std.int(480 / tileHeight);

	public var _fragPool:FlxSprite;
	public var _appleSprite:FlxSprite;

	public var snakeTailColor = 0xFF44F44F;
	public var snakeHeadColor = 0xFF2B9E32;

	public var snakeRaimbow:Bool = false;

	var db:FlxText;
	var scoreTxt:FlxText;
	var score:Int = 0;

	override public function create()
	{
		super.create();

		for (i in 0...4)
		{
			snake.push(FlxPoint.get(i, 0));
		}

		camera.bgColor = 0xFF616161;

		_fragPool = new FlxSprite();
		_fragPool.makeGraphic(tileWidth, tileHeight, 0xFF44F44F);
		add(_fragPool);

		_appleSprite = new FlxSprite();
		_appleSprite.makeGraphic(tileWidth, tileHeight, 0xFFFF0000);
		add(_appleSprite);

		db = new FlxText(5, 5);
		db.setFormat(null, 16, 0xFF3E1270, CENTER);
		add(db);

		scoreTxt = new FlxText(0, 0);
		scoreTxt.setFormat(null, 32, 0xFFFFFFFF, RIGHT);
		add(scoreTxt);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		scoreTxt.text = 'Score: $score';
		scoreTxt.x = FlxG.width - scoreTxt.width;
		scoreTxt.y = 10;

		final h = snake[snake.length - 1];
		db.text = '-- Snake Info--\nHead Pos:\n{x: ${h.x} y: ${h.y}}\n\nDirection:\n{x: $xDir y: $yDir}\nTail Length: ${snake.length}\nRaimbow: $snakeRaimbow\nAI Enabled: $AI';
		updateDeath();
		updateTail();
		updateInput();
		updateEating();
	}
	override public function draw():Void
	{
		drawSnake();

		super.draw();
	}

	function updateBounds(pos:FlxPoint)
	{
		if (pos.x > PTW_AMOUNT)
			pos.x = 0;
		else if (pos.x < 0)
			pos.x = PTW_AMOUNT;

		if (pos.y > PTH_AMOUNT)
			pos.y = 0;
		else if (pos.y < 0)
			pos.y = PTH_AMOUNT;
	}
	
	function updateDeath()
	{
		var keys = [];
		var death = false;

		var headKey = snake[snake.length - 1].toString();

		for (i in 0...snake.length - 1)
		{
			final pos = snake[i];
			
			var newKey = pos.toString();
			if (keys.contains(headKey))
			{
				death = true;
				break;
			}
			keys.push(newKey);
		}
		if (!death)
			return;

		FlxG.resetState();
	}
	function updateEating()
	{
		var head = snake[snake.length - 1];

		if (head.x == apple.x && head.y == apple.y)
		{
			var last = snake[0];

			snake.insert(0, FlxPoint.get(last.x - xDir, last.y - yDir));
			apple.set(FlxG.random.int(1, PTW_AMOUNT - 1), FlxG.random.int(1, PTH_AMOUNT - 1));
			score++;
		}
		
		_appleSprite.setPosition(apple.x * tileWidth, apple.y * tileHeight);
	}
	function drawSnake()
	{
		var snakeColors = Other.generateRainbowColors(snake.length);

		for (pos in snake)
		{
			updateBounds(pos);

			_fragPool.color = !snakeRaimbow ? (pos != snake[snake.length - 1] ? snakeTailColor : snakeHeadColor) : snakeColors[0];
			_fragPool.setPosition(pos.x * tileWidth, pos.y * tileHeight);
			_fragPool.draw();

			snakeColors.shift();

			continue;
			
			// FUCK U GRAPHICS
			if (FlxG.renderBlit) {
				var rect = new Rectangle(pos.x * tileWidth, pos.y * tileHeight, tileWidth, tileHeight);
				camera.buffer.fillRect(rect, 0xFF44F44F);
			} else {
				camera.canvas.graphics.lineStyle(null, 0xFF44F44F);
				camera.canvas.graphics.drawRect(pos.x * tileWidth, pos.y * tileHeight, tileWidth, tileHeight);
			}
		}
	}
	var updateDelay = 0.1;
	var counter = 0.0;
	function updateTail()
	{
		if (counter < updateDelay)
		{
			counter += FlxG.elapsed;
			return;
		}
		// remove last tail frag. and weak his point
		snake.shift().putWeak();

		// add new tail fragmnt
		var lastPos = snake[snake.length - 1];
		
		snake.push(FlxPoint.get(lastPos.x + xDir, lastPos.y + yDir));

		counter = 0;
	}
	function updateInput()
	{
		// if ai, just ignore the user input lol
		if (AI) {
			computeSnakeAi();
			return;
		}

		var left = FlxG.keys.justPressed.LEFT;
		var right = FlxG.keys.justPressed.RIGHT;
		var up = FlxG.keys.justPressed.UP;
		var down = FlxG.keys.justPressed.DOWN;

		if ((left || right) && xDir == 0)
		{
			yDir = 0;

			xDir = left ? -1 : 1;
		}
		if ((down || up) && yDir == 0)
		{
			xDir = 0;

			yDir = up ? -1 : 1;
		}
	}

	// wanna die... this isnt even a good way to do it, but it works so whatev
	var AI:Bool = false;
	function computeSnakeAi()
	{
		var head = snake[snake.length - 1];
		var xDiff = Std.int(apple.x - head.x);
		var yDiff = Std.int(apple.y - head.y);

		var nXDir = 0;
		var nYDir = 0;

		if (Math.abs(xDiff) > Math.abs(yDiff))
		{
			nXDir = xDiff > 0 ? 1 : -1;
			nYDir = 0;
		} 
		else
		{
			nXDir = 0;
			nYDir = yDiff > 0 ? 1 : -1;
		}

		var collision = false;
		var nextHeadX = Std.int(head.x + nXDir);
		var nextHeadY = Std.int(head.y + nYDir);

		for (i in 0...snake.length - 1)
		{
			var segment = snake[i];
			if (Std.int(segment.x) == nextHeadX && Std.int(segment.y) == nextHeadY)
			{
				collision = true;
				break;
			}
		}

		if (collision || (nXDir == -xDir && yDir == 0) || (nYDir == -yDir && xDir == 0))
		{
			var altDirFounded = false;

			var directions = [
				{x: 0, y: 1}, // move down
				{x: 0, y: -1}, // move up
				{x: 1, y: 0},  // move right
				{x: -1, y: 0}  // move letf
			];

			for (dir in directions)
			{
				if (dir.x != -xDir || dir.y != -yDir)
				{
					var altHeadX = Std.int(head.x + dir.x);
					var altHeadY = Std.int(head.y + dir.y);
					var altCollision = false;

					for (i in 0...snake.length - 1)
					{
						var segment = snake[i];
						if (Std.int(segment.x) == altHeadX && Std.int(segment.y) == altHeadY)
						{
							altCollision = true;
							break;
						}
					}

					if (!altCollision)
					{
						nXDir = dir.x;
						nYDir = dir.y;
						altDirFounded = true;
						break;
					}
				}
			}
			if (!altDirFounded) 
			{
				nXDir = 0;
				nYDir = 0;
			}
		}

		if (nXDir != 0 || nYDir != 0)
		{
			xDir = nXDir;
			yDir = nYDir;
		}

		db.text += '\n\n-- AI INFO --\nApple Pos Diff:\n{x: $xDiff y: $yDiff}\nNext Head Pos:\n{x: $nextHeadX y: $nextHeadY}\nAvoiding Body: $collision';
	}
}