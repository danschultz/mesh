package reflection
{
	/**
	 * Creates a new instance of the given class by using the given arguments.
	 * 
	 * @param clazz The class to initialize.
	 * @param args The set of arguments to pass to the class's constructor.
	 * @return An initialized instance of the class.
	 */
	public function newInstance(clazz:Class, ... args):*
	{
		switch (args.length)
		{
			case 0:
				return new clazz();
				break;
			case 1:
				return new clazz(args[0]);
				break;
			case 2:
				return new clazz(args[0], args[1]);
				break;
			case 3:
				return new clazz(args[0], args[1], args[2]);
				break;
			case 4:
				return new clazz(args[0], args[1], args[2], args[3]);
				break;
			case 5:
				return new clazz(args[0], args[1], args[2], args[3], args[4]);
				break;
			case 6:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5]);
				break;
			case 7:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
				break;
			case 8:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
				break;
			case 9:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
				break;
			case 10:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
				break;
			case 11:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10]);
				break;
			case 12:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11]);
				break;
			case 13:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12]);
				break;
			case 14:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13]);
				break;
			case 15:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14]);
				break;
			case 16:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15]);
				break;
			case 17:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16]);
				break;
			case 18:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17]);
				break;
			case 19:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18]);
				break;
			case 20:
				return new clazz(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19]);
				break;
			default:
				return null;
		}
		return null;
	}
}