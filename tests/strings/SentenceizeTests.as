package strings
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class SentenceizeTests
	{
		private var _tests:Array = [];
		
		[Before]
		public function setup():void
		{
			_tests.push({input:"the quick brown fox, jumped over the lazy dog.", expected:"The quick brown fox, jumped over the lazy dog."});
			_tests.push({input:"The Quick Brown Fox, Jumped Over the Lazy Dog.", expected:"The Quick Brown Fox, Jumped Over the Lazy Dog."});
			_tests.push({input:"the quick brown fox, jumped over the lazy dog", expected:"The quick brown fox, jumped over the lazy dog"});
			_tests.push({input:"the quick brown fox; jumped over the lazy dog", expected:"The quick brown fox; jumped over the lazy dog"});
			_tests.push({input:"the quick brown fox. jumped over the lazy dog", expected:"The quick brown fox. Jumped over the lazy dog"});
			_tests.push({input:"the quick brown fox! jumped over the lazy dog", expected:"The quick brown fox! Jumped over the lazy dog"});
			_tests.push({input:"the quick brown fox? jumped over the lazy dog.", expected:"The quick brown fox? Jumped over the lazy dog."});
		}
		
		[Test]
		public function testSentenceize():void
		{
			for each (var test:Object in _tests) {
				assertThat("sentenceize failed for '" + test.input + "'", sentenceize(test.input), equalTo(test.expected));
			}
		}
	}
}