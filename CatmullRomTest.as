package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;

	[SWF(width="400", height="400", backgroundColor="0xffffff")]
	public class CatmullRomTest extends Sprite {

		private const pA:Point=new Point(50, 120);
		private const pB:Point=new Point(200, 250);
		private const pC:Point=new Point(350, 120);
		private const pD:Point=new Point(480, 250);

		private const pStart:Point=new Point(0, 0);
		private const pEnd:Point=new Point(400, 0);

		public function CatmullRomTest() {
			super();


			stage.addEventListener(Event.ENTER_FRAME, loop);
		}

		private function loop(e:Event):void {
			var t:Number=getTimer() * 0.001;
//			pA.y=Math.sin(t) * 100 + 150;
//			pB.y=Math.cos(t) * 100 + 150;
//			pC.y=Math.cos(t + 1) * 100 + 150;
//			pD.y=Math.sin(t + 1) * 100 + 150;

			pA.setTo(50, 350);
			pB.setTo(230, 50);
			pC.setTo(250, 60);
			pD.setTo(370, 380);

			this.graphics.clear();
			this.graphics.lineStyle(0);
			this.graphics.drawCircle(pA.x, pA.y, 5);
			this.graphics.drawCircle(pB.x, pB.y, 5);
			this.graphics.drawCircle(pC.x, pC.y, 5);
			this.graphics.drawCircle(pD.x, pD.y, 5);

			drawCRL(pStart, pA, pB, pC, mouseX * 0.1);
			drawCRL(pA, pB, pC, pD, mouseX * 0.1);
			drawCRL(pB, pC, pD, pEnd, mouseX * 0.1);

			drawCRL_chordal(pStart, pA, pB, pC, mouseX * 0.1);
			drawCRL_chordal(pA, pB, pC, pD, mouseX * 0.1);
			drawCRL_chordal(pB, pC, pD, pEnd, mouseX * 0.1);
			
			drawCRL_centripetal(pStart, pA, pB, pC, mouseX * 0.1);
			drawCRL_centripetal(pA, pB, pC, pD, mouseX * 0.1);
			drawCRL_centripetal(pB, pC, pD, pEnd, mouseX * 0.1);
		}

		
		/**
		 * draw spline
		 */
		private function drawCRL(pa:Point, pb:Point, pc:Point, pd:Point, step:int=5):void {
			if (step < 2) {
				step=2;
			}

			this.graphics.lineStyle(1, 0xff00);
			this.graphics.moveTo(pb.x, pb.y);
			for (var i:int=0; i < step; i++) {
				var p:Point=catmullRom_uniform(pa, pb, pc, pd, i / (step - 1));
				this.graphics.lineTo(p.x, p.y);
			}
		}

		private function drawCRL_chordal(pa:Point, pb:Point, pc:Point, pd:Point, step:int=5):void {
			if (step < 2) {
				step=2;
			}

			this.graphics.lineStyle(1, 0xff0000);
			this.graphics.moveTo(pb.x, pb.y);
			for (var i:int=0; i < step; i++) {
				var p:Point=catmullRom_chordal(pa, pb, pc, pd, i / (step - 1));
				this.graphics.lineTo(p.x, p.y);
			}
		}
		
		private function drawCRL_centripetal(pa:Point, pb:Point, pc:Point, pd:Point, step:int=5):void {
			if (step < 2) {
				step=2;
			}
			
			this.graphics.lineStyle(1, 0xff);
			this.graphics.moveTo(pb.x, pb.y);
			for (var i:int=0; i < step; i++) {
				var p:Point=catmullRom_centripetal(pa, pb, pc, pd, i / (step - 1));
				this.graphics.lineTo(p.x, p.y);
			}
		}


		/**
		 * implementation
		 */
		private function catmullRom(value1:Number, value2:Number, value3:Number, value4:Number, amount:Number):Number {
			// Using formula from http://www.mvps.org/directx/articles/catmull/

			var amountSquared:Number=amount * amount;
			var amountCubed:Number=amountSquared * amount;
			return (0.5 * (2.0 * value2 +
				(value3 - value1) * amount +
				(2.0 * value1 - 5.0 * value2 + 4.0 * value3 - value4) * amountSquared +
				(3.0 * value2 - value1 - 3.0 * value3 + value4) * amountCubed));
		}

		private function catmullRom_uniform(value1:Point, value2:Point, value3:Point, value4:Point, amount:Number):Point {
			return new Point(catmullRom(value1.x, value2.x, value3.x, value4.x, amount),
				catmullRom(value1.y, value2.y, value3.y, value4.y, amount));
		}


		private function catmullRom_chordal(value1:Point, value2:Point, value3:Point, value4:Point, amount:Number):Point {
			// http://stackoverflow.com/questions/9489736/catmull-rom-curve-with-no-cusps-and-no-self-intersections/19283471#19283471
			return cubicCatmull_RomCurve(value1, value2, value3, value4, amount, 0.5);
		}
		
		private function catmullRom_centripetal(value1:Point, value2:Point, value3:Point, value4:Point, amount:Number):Point {
			// http://stackoverflow.com/questions/9489736/catmull-rom-curve-with-no-cusps-and-no-self-intersections/19283471#19283471
			return cubicCatmull_RomCurve(value1, value2, value3, value4, amount, 0.25);
		}

		private function cubicCatmull_RomCurve(value1:Point, value2:Point, value3:Point, value4:Point, amount:Number, pow:Number):Point {
			var dx:Number=value2.x - value1.x;
			var dy:Number=value2.y - value1.y;
			var t1:Number=Math.pow(dx * dx + dy * dy, pow);
			dx=value3.x - value2.x;
			dy=value3.y - value2.y;
			var t2:Number=t1 + Math.pow(dx * dx + dy * dy, pow);
			dx=value4.x - value3.x;
			dy=value4.y - value3.y;
			var t3:Number=t2 + Math.pow(dx * dx + dy * dy, pow);

			var es:Number=t2 - t1;
			return new Point(interpolate(value1.x, value2.x, value3.x, value4.x, 0, t1, t2, t3, t1 + (es * amount)),
				interpolate(value1.y, value2.y, value3.y, value4.y, 0, t1, t2, t3, t1 + (es * amount)));
		}


		private function interpolate(p1:Number, p2:Number, p3:Number, p4:Number, t1:Number, t2:Number, t3:Number, t4:Number, t:Number):Number {
			var L01:Number=p1 * (t2 - t) / (t2 - t1) + p2 * (t - t1) / (t2 - t1);
			var L12:Number=p2 * (t3 - t) / (t3 - t2) + p3 * (t - t2) / (t3 - t2);
			var L23:Number=p3 * (t4 - t) / (t4 - t3) + p4 * (t - t3) / (t4 - t3);
			var L012:Number=L01 * (t3 - t) / (t3 - t1) + L12 * (t - t1) / (t3 - t1);
			var L123:Number=L12 * (t4 - t) / (t4 - t2) + L23 * (t - t2) / (t4 - t2);
			var C12:Number=L012 * (t3 - t) / (t3 - t2) + L123 * (t - t2) / (t3 - t2);
			return C12;
		}


	}
}
