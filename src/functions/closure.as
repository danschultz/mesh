package functions
{
	public function closure(func:Function):Function
	{
		var wrapper:Function = function(...args):*
		{
			return func.apply(null, args.slice(0, func.length));
		};
		return wrapper;
	}
}