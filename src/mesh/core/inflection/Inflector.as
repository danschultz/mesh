package mesh.core.inflection
{
	import collections.HashSet;

	/**
	 * A class that manages and handles rules for pluralizing and singularizing a word.
	 * A singleton instance that contains a standard set of rules can be retrieved using
	 * <code>Inflector.inflections()</code>.
	 * 
	 * @see pluralize()
	 * @see singularize()
	 * 
	 * @author Dan Schultz
	 */
	public class Inflector
	{
		private var _plurals:Array = new Array();
		private var _singulars:Array = new Array();
		private var _ignored:HashSet = new HashSet();
		
		/**
		 * Constructor.
		 */
		public function Inflector()
		{
			
		}
		
		private static var INSTANCE:Inflector;
		/**
		 * Returns a singleton instance of an inflector that contains a standard set of
		 * singularized and pluralized words.
		 * 
		 * @return An inflector.
		 */
		public static function inflections():Inflector
		{
			if (INSTANCE == null) {
				INSTANCE = new Inflector();
				
				INSTANCE.plural(/$/, 's');
				INSTANCE.plural(/s$/i, 's');
				INSTANCE.plural(/(ax|test)is$/i, '$1es');
				INSTANCE.plural(/(octop|vir)us$/i, '$1i');
				INSTANCE.plural(/(alias|status)$/i, '$1es');
				INSTANCE.plural(/(bu)s$/i, '$1ses');
				INSTANCE.plural(/(buffal|tomat)o$/i, '$1oes');
				INSTANCE.plural(/([ti])um$/i, '$1a');
				INSTANCE.plural(/sis$/i, 'ses');
				INSTANCE.plural(/(?:([^f])fe|([lr])f)$/i, '$1$2ves');
				INSTANCE.plural(/(hive)$/i, '$1s');
				INSTANCE.plural(/([^aeiouy]|qu)y$/i, '$1ies');
				INSTANCE.plural(/(x|ch|ss|sh)$/i, '$1es');
				INSTANCE.plural(/(matr|vert|ind)(?:ix|ex)$/i, '$1ices');
				INSTANCE.plural(/([m|l])ouse$/i, '$1ice');
				INSTANCE.plural(/^(ox)$/i, '$1en');
				INSTANCE.plural(/(quiz)$/i, '$1zes');
					
				INSTANCE.singular(/s$/i, '');
				INSTANCE.singular(/(n)ews$/i, '$1ews');
				INSTANCE.singular(/([ti])a$/i, '$1um');
				INSTANCE.singular(/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, '$1$2sis');
				INSTANCE.singular(/(^analy)ses$/i, '$1sis');
				INSTANCE.singular(/([^f])ves$/i, '$1fe');
				INSTANCE.singular(/(hive)s$/i, '$1');
				INSTANCE.singular(/(tive)s$/i, '$1');
				INSTANCE.singular(/([lr])ves$/i, '$1f');
				INSTANCE.singular(/([^aeiouy]|qu)ies$/i, '$1y');
				INSTANCE.singular(/(s)eries$/i, '$1eries');
				INSTANCE.singular(/(m)ovies$/i, '$1ovie');
				INSTANCE.singular(/(x|ch|ss|sh)es$/i, '$1');
				INSTANCE.singular(/([m|l])ice$/i, '$1ouse');
				INSTANCE.singular(/(bus)es$/i, '$1');
				INSTANCE.singular(/(o)es$/i, '$1');
				INSTANCE.singular(/(shoe)s$/i, '$1');
				INSTANCE.singular(/(cris|ax|test)es$/i, '$1is');
				INSTANCE.singular(/(octop|vir)i$/i, '$1us');
				INSTANCE.singular(/(alias|status)es$/i, '$1');
				INSTANCE.singular(/^(ox)en/i, '$1');
				INSTANCE.singular(/(vert|ind)ices$/i, '$1ex');
				INSTANCE.singular(/(matr)ices$/i, '$1ix');
				INSTANCE.singular(/(quiz)zes$/i, '$1');
				INSTANCE.singular(/(database)s$/i, '$1');
				
				INSTANCE.irregular('person', 'people');
				INSTANCE.irregular('man', 'men');
				INSTANCE.irregular('child', 'children');
				INSTANCE.irregular('sex', 'sexes');
				INSTANCE.irregular('move', 'moves');
				INSTANCE.irregular('cow', 'kine');
				INSTANCE.irregular('goose', 'geese');
				
				INSTANCE.uncountable("equipment");
				INSTANCE.uncountable("information");
				INSTANCE.uncountable("rice");
				INSTANCE.uncountable("money");
				INSTANCE.uncountable("species");
				INSTANCE.uncountable("series");
				INSTANCE.uncountable("jeans");
				
				// game animals are normally uncountable
				INSTANCE.uncountable("deer");
				INSTANCE.uncountable("moose");
				INSTANCE.uncountable("sheep");
				INSTANCE.uncountable("salmon");
				INSTANCE.uncountable("bison");
				INSTANCE.uncountable("moose");
				INSTANCE.uncountable("pike");
				INSTANCE.uncountable("trout");
				INSTANCE.uncountable("fish");
				INSTANCE.uncountable("sheep");
				INSTANCE.uncountable("swine");
			}
			
			return INSTANCE;
		}
		
		/**
		 * Adds a set of words to be ignored during inflections.
		 * 
		 * @param words A set of words.
		 */
		public function uncountable(... words):void
		{
			_ignored.addAll(words);
		}
		
		/**
		 * Adds a pluralization rule and a replacement for when the rule is matched. The rule
		 * can either be a <code>String</code> or regular expression. <code>replacement</code>
		 * honors the definition of <code>String.replace()</code>.
		 * 
		 * @param rule The pluralization rule.
		 * @param replacement The replacement.
		 */
		public function plural(rule:Object, replacement:String):void
		{
			if (rule is String) {
				_ignored.removeAll([rule, replacement]);
			}
			_plurals.unshift(rule, replacement);
		}
		
		/**
		 * Adds a singularization rule and a replacement for when the rule is matched. The rule
		 * can either be a <code>String</code> or regular expression. <code>replacement</code>
		 * honors the definition of <code>String.replace()</code>.
		 * 
		 * @param rule The singularization rule.
		 * @param replacement The replacement.
		 */
		public function singular(rule:Object, replacement:String):void
		{
			if (rule is String) {
				_ignored.removeAll([rule, replacement]);
			}
			_singulars.unshift(rule, replacement);
		}
		
		/**
		 * Adds a singularization and pluralization version for an irregular word. Regular
		 * expressions are not supported.
		 * 
		 * @param singularized The singular version of a word.
		 * @param pluralized The plural version of the word.
		 */
		public function irregular(singularized:String, pluralized:String):void
		{
			_ignored.removeAll([singular, plural]);
			
			if (singularized.substr(0, 1).toUpperCase() == pluralized.substr(0, 1).toUpperCase()) {
				plural(new RegExp("(" + singularized.substr(0, 1) + ")" + singularized.substr(1) + "$", "i"), "$1" + pluralized.substr(1));
				plural(new RegExp("(" + pluralized.substr(0, 1) + ")" + pluralized.substr(1) + "$", "i"), "$1" + pluralized.substr(1));
				singular(new RegExp("(" + pluralized.substr(0, 1) + ")" + pluralized.substr(1) + "$", "i"), "$1" + singularized.substr(1));
			} else {
				plural(new RegExp(singularized.substr(0, 1).toUpperCase() + "(?i)" + singularized.substr(1) + "$"), pluralized.substr(0, 1).toUpperCase() + pluralized.substr(1));
				plural(new RegExp(singularized.substr(0, 1).toLowerCase() + "(?i)" + singularized.substr(1) + "$"), pluralized.substr(0, 1).toLowerCase() + pluralized.substr(1));
				plural(new RegExp(pluralized.substr(0, 1).toUpperCase() + "(?i)" + pluralized.substr(1) + "$"), pluralized.substr(0, 1).toUpperCase() + pluralized.substr(1));
				plural(new RegExp(pluralized.substr(0, 1).toLowerCase() + "(?i)" + pluralized.substr(1) + "$"), pluralized.substr(0, 1).toLowerCase() + pluralized.substr(1));
				singular(new RegExp(pluralized.substr(0, 1).toUpperCase() + "(?i)" + pluralized.substr(1)), singularized.substr(0, 1).toUpperCase() + singularized.substr(1));
				singular(new RegExp(pluralized.substr(0, 1).toLowerCase() + "(?i)" + pluralized.substr(1)), singularized.substr(0, 1).toLowerCase() + singularized.substr(1));
			}
		}
		
		/**
		 * Returns a pluralized version of the given word.
		 * 
		 * @param word The word to pluralize.
		 * @return A pluralized version of <code>word</code>.
		 */
		public function pluralize(word:String):String
		{
			if (word.length == 0 || _ignored.contains(word)) {
				return word;
			}
			
			for (var i:int = 0; i < _plurals.length; i = i+2) {
				var result:String = word.replace(_plurals[i], _plurals[i+1]);
				if (result != word) {
					return result;
				}
			}
			
			return word;
		}
		
		/**
		 * Returns a singular version of the given word.
		 * 
		 * @param word The word to singularize.
		 * @return A singularized word.
		 */
		public function singularize(word:String):String
		{
			if (word.length == 0 || _ignored.contains(word)) {
				return word;
			}
			
			for (var i:int = 0; i < _singulars.length; i = i+2) {
				var result:String = word.replace(_singulars[i], _singulars[i+1]);
				if (result != word) {
					return result;
				}
			}
			
			return word;
		}
	}
}