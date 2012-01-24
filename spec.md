# Mesh - v0.3.0
Mesh is an open-source persistence framework for [Adobe Flex](http://www.adobe.com/products/flex/). Its aim is to make the retrieval and persistence of your application's model as transparent as possible.

Mesh provides the mechanisms for defining the associations between your models, tracking which objects need to be saved, validating the integrity of your data, and mapping your models to backend services. In addition, Mesh is completely agnostic to the backend service that you use. It can be used with any existing AMF, REST, SOAP service, and hypothetically an AIR application running a SQLite database.

Mesh follows the guidelines of [semantic versioning](http://www.semver.org).

## Store
At the heart of Mesh, is the store. The store is where all the models of your application are kept.

### Queries
Queries are asynchronous objects used to find data within the store.

	// Creating queries
	query = store.query(Person).find(1);
	query = store.query(Person).findAll();

	// Executing a query
	query = store.query(Person).find(1);
	var person:Person = query.execute();

	query = store.query(Person).findAll();
	var results:IList = query.execute();

	// Listening to query completion
	query = store.query(Person).findAll();
	query.addEventListener(QueryEvent.FINISHED, function(event:QueryEvent):void
	{
		
	});
	query.execute();

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