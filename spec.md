# Mesh - v0.3.0
Mesh is an open-source persistence framework for [Adobe Flex](http://www.adobe.com/products/flex/). Its aim is to make the retrieval and persistence of your application's model as transparent as possible.

Mesh provides the mechanisms for defining the associations between your models, tracking which objects need to be saved, validating the integrity of your data, and mapping your models to backend services. In addition, Mesh is completely agnostic to the backend service that you use. It can be used with any existing AMF, REST, SOAP service, and hypothetically an AIR application running a SQLite database.

Mesh follows the guidelines of [semantic versioning](http://www.semver.org).

## Records
Model classes in Mesh are defined as `Record` sub-classes. Records track how your application modifies them. They detect when their properties change, when the application destroys them, and when they're data is persisted to the backend. This information is used to determine when and how to persist your data.

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

## Store
The `Store` is where the records of your application are kept. You use the store to retrieve and persist the data in your application. Your application is responsible for initializing a store.

*Note:* Usually only one store is initialized per application.

### Data Adaptor
The store looks to its data adaptor to connect itself with the backend for retrieval and persistence of its data.

#### Data Caching
Whenever a data adaptor receives data from the backend, it adds it to the store's data cache. On the next store query, the adaptor can opt to load cached data for records that haven't been materialized yet.

### Finding Records
Records are loaded by quering the store. Once a record is loaded, it's kept in the store until explicitly removed. Multiple queries to the same record ID will return the same record instance.

**Example:** Executing queries
	// Retrieve a person
	var person:Person = records.find(Person).id(1);

	// Retrieve everyone
	var everyone:ResultList = records.find(Person).all();

	// Search for people
	var males:ResultList = records.find(Person).where({gender:"m"});

### Saving Records
The store is responsible for persisting your model. To prevent possible race conditions, only a single save can happen at a time. Multiple save calls will be queued.

**Example:** Executing a save.
	// Saving all records.
	var request:Request = records.save();

	// Saving a subset of records.
	request = records.save(person1, person2);