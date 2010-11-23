package mesh
{
	import mx.collections.ArrayList;
	import mx.collections.ICollectionView;
	import mx.collections.ListCollectionView;

	public class Post extends Entity
	{
		public function Post()
		{
			
		}
		
		private var _comments:ArrayList = new ArrayList();
		[Relationship(to="mesh.Comment")]
		public function get comments():ArrayList
		{
			return _comments;
		}
		
		private var _author:Author;
		[Relationship]
		public function get author():Author
		{
			return _author;
		}
		public function set author(value:Author):void
		{
			_author = value;
		}
	}
}