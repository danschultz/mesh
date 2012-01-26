# Mesh - v0.3.0
Mesh is an open-source persistence framework for [Adobe Flex](http://www.adobe.com/products/flex/). Its aim is to make the retrieval and persistence of your application's model as transparent as possible.

Mesh provides the mechanisms for defining the associations between your models, tracking which objects need to be saved, validating the integrity of your data, and mapping your models to backend services. In addition, Mesh is completely agnostic to the backend service that you use. It can be used with any existing AMF, REST, SOAP service, and hypothetically an AIR application running a SQLite database.

Mesh follows the guidelines of [semantic versioning](http://www.semver.org).

## Store
At the heart of Mesh, is the store. The store is where all the models of your application are kept.

### Queries
Queries are used to find data within the store. You can query for a single record, or many records.

	// Creating queries
	var person:Person = store.query(Person).find(1);
	var people:ResultsList = store.query(Person).findAll();

Sometimes you'll want to load the queries through the data source. Calling the query's `load()` method will tell the store's data source to load the data for that query. It's up to the data source to interpret the query and map it to the backend services that are available. Multiple calls to `load()` will ensure that the query is only loaded once. Calling `refresh()` will force an reload of the query.

	// Load a query from the data source
	var males:ResultsList = store.query(Person).where({sex:"m"}).load();

	// Reload the query
	males.refresh();

Sometimes you'll want to know to when the query's data has been loaded. The event listener will need to be added before the call to `load()`. This ensures the listener exists for synchronous data calls.

	// Listening for loaded data
	person = store.query(Person).find(1);
	person.loadOperation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
	{
		
	});
	person.load();

Sometimes you'll need to find data based on some condition.

	// Search query
	var people:ResultsList = store.query(Person).where({name:"Jimmy Page"});

`ResultsList`'s are queries that have multiple results. These sets are automatically updated whenever the store is updated. You cannot add or remove elements directly from the result list. These operations must happen through the store.

	// Query for everyone
	var people:ResultsList = store.query(Person).findAll();
	trace(people.length); // 5

	// Remove a person from the store
	var person:Person = store.query(Person).find(1);
	person.remove();
	trace(people.length); // 4

### Data Source
A data source is used to retrieve and persist data for the store. The data source class defines a template that sub-classes must override in order to fully function. These methods are used to create, retrieve, delete, and update data on the server.

### Saving Records
The store is responsible for persisting your model. To prevent possible race conditions, only a single save can happen at a time. Multiple save calls will be queued.

**Example:** Executing a save.
	// Saving all records.
	var request:Request = records.save();

	// Saving a subset of records.
	request = records.save(person1, person2);

## Records
Model classes in Mesh are defined as `Record`s. Records track how your application modifies the model. They detect when their properties change, when the application destroys them, and when they're data is persisted to the backend. This information is used to determine when and how to persist your data.

**Example:** A simple model.
	package myapp
	{
		public class Person extends Record
		{
			[Bindable] public var name:String;
			[Bindable] public var age:int;
		}
	}

### Record Associations
Records may define has-one or has-many associations with other records. These definitions are used for lazy-loading data that is associated with a record.

**Example:** Definining Associations
	package myapp
	{
		public class Person extends Record
		{
			[Bindable] public var name:String;
			[Bindable] public var age:int;
			[Bindable] public var bestFriendId:int;

			[Bindable] public var bestFriend:Person;
			[Bindable] public var friends:HasManyAssociation;

			public function Person()
			{
				super();

				hasOne("bestFriend", {foreignKey:"bestFriendId"}); // Defining the foreign key isn't required here. Defaults to association name + "Id".
				hasMany("friends", function(store:Store):ResultList
				{
					return store.find(Person).where({friend:this});
				});
			}
		}
	}

Has-one associations are populated when the foreign keys change, and the record belongs to the store. If the record has not been retrieved from the adaptor, an empty record is created. The empty record will have its ID populated from the foreign key. The has-one association can then be loaded like so: `person.bestFriend.load();`.

Has-many associations are populated through a call to load, like so: `person.friends.load();`.