package mesh.core.range
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;
	
	import mesh.core.reflection.clazz;

	/**
	 * A type that represents values between a lower and upper limit, such as a range 
	 * <em>from 5 up to 10</em>. <code>Range</code> has built in support for integers, single 
	 * character strings, and dates.
	 * 
	 * <p>
	 * Ranges supports iteration through the <code>for each..in</code> syntax.
	 * 
	 * <pre listing="3.0">
	 * for each (var num:int in Range.from(5).to(10)) {
	 * 	trace(num);
	 * }
	 * 
	 * // traces
	 * // 5
	 * // 6
	 * // 7
	 * // 8
	 * // 9
	 * // 10
	 * </pre>
	 * </p>
	 * 
	 * <p>
	 * You may sub-class <code>Range</code> to support custom types of objects. You will need
	 * to override the following methods:
	 * 
	 * <ul>
	 * <li><code>decrement()</code></li>
	 * <li><code>increment()</code></li>
	 * <li><code>length</code></li>
	 * </ul>
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class Range extends Proxy
	{
		private var _isExclusive:Boolean;
		private var _isDecreasing:Boolean;
		
		public function Range(from:*, to:*, exclusive:Boolean = false)
		{
			var clazz:Class = clazz(to);
			if (!(from is clazz)) {
				throw new ArgumentError("Range values must be the same type.");
			}
			
			_from = from;
			_to = to;
			_isExclusive = exclusive;
			_isDecreasing = from > to;
		}
		
		public static function from(value:*):RangeBuilder
		{
			var clazz:Class;
			
			if (value is Number) {
				clazz = IntRange;
			} else if (value is String) {
				clazz = CharRange;
			} else if (value is Date) {
				clazz = DateRange;
			} else {
				throw new IllegalOperationError("Range.from() only supports Number, String, and Date.");
			}
			
			return new RangeBuilder(clazz, value);
		}
		
		public function contains(item:Object):Boolean
		{
			try {
				return item >= min && (!_isExclusive ? item <= max : item < max);
			} catch (e:Error) {
				
			}
			return false;
		}
		
		public function forEach(block:Function):void
		{
			step(1, block);
		}
		
		public function step(size:int, block:Function):void
		{
			size = Math.max(1, size);
			
			var iterator:RangeIterator = newIterator(size);
			while (iterator.hasNext()) {
				block(iterator.value);
				iterator.next();
			}
		}
		
		public function toArray():Array
		{
			var result:Array = [];
			forEach(function(element:Object):void
			{
				result.push(element);
			});
			return result;
		}
		
		public function toString():String
		{
			return from + ".." + to;
		}
		
		protected function decrease(value:*, size:int):*
		{
			throw new IllegalOperationError(getQualifiedClassName(this) + ".decrease() is not implemented.");
		}
		
		protected function increase(value:*, size:int):*
		{
			throw new IllegalOperationError(getQualifiedClassName(this) + ".increase() is not implemented.");
		}
		
		/**
		 * @private
		 */
		override flash_proxy function nextName(index:int):String
		{
			return (index-1).toString();
		}
		
		private var _iterator:RangeIterator;
		/**
		 * @private
		 */
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (index == 0) {
				_iterator = newIterator(1);
			}
			return _iterator.hasNext() ? index+1 : 0;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function nextValue(index:int):*
		{
			_iterator.next();
			return _iterator.value;
		}
		
		private function newIterator(size:int):RangeIterator
		{
			return new RangeIterator(this, new RangeSequence(from, size, _isDecreasing ? decrease : increase));
		}
		
		private var _from:*;
		public function get from():*
		{
			return _from;
		}
		
		private var _to:*;
		public function get to():*
		{
			return _to;
		}
		
		public function get min():*
		{
			return to < from ? to : from;
		}
		
		public function get max():*
		{
			return to > from ? to : from;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			throw new IllegalOperationError(getQualifiedClassName(this) + ".length is not implemented.");
		}
	}
}

import mesh.core.range.Range;

class RangeIterator
{
	private var _range:Range;
	private var _sequence:RangeSequence;
	
	public function RangeIterator(range:Range, sequence:RangeSequence)
	{
		_range = range;
		_sequence = sequence;
	}
	
	public function hasNext():Boolean
	{
		return _range.contains(_sequence.value); 
	}
	
	public function next():Object
	{
		_value = _sequence.value;
		_sequence = _sequence.next();
		return value;
	}
	
	private var _value:*;
	public function get value():*
	{
		return _value;
	}
}

class RangeSequence
{
	private var _incrementorOrDecrementor:Function;
	private var _size:int;
	
	public function RangeSequence(value:*, size:int, incrementorOrDecrementor:Function)
	{
		_value = value;
		_size = size;
		_incrementorOrDecrementor = incrementorOrDecrementor;
	}
	
	public function next():RangeSequence
	{
		return new RangeSequence(_incrementorOrDecrementor(value, _size), _size, _incrementorOrDecrementor);
	}
	
	private var _value:*;
	public function get value():*
	{
		return _value;
	}
}