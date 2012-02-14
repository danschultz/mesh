# Mesh - v0.3.0
Mesh is an open-source persistence framework for [Adobe Flex](http://www.adobe.com/products/flex/). Its aim is to make the retrieval and persistence of your application's model as transparent as possible.

Mesh provides the mechanisms for defining the associations between your models, tracking which objects need to be saved, validating the integrity of your data, and mapping your models to backend services. In addition, Mesh is completely agnostic to the backend service that you use. It can be used with any existing AMF, REST, SOAP service, and hypothetically an AIR application running a SQLite database.

Mesh follows the guidelines of [semantic versioning](http://www.semver.org).

## Store
The store is what your application interacts with to load, query, and persist data changes. Any records that are retrieved from your backend are stored here for your application to use.

### Queries
Queries are used to find data within the store. You can search for a single record, or many records.

	// Creating queries
	var person:Person = store.query(Person).find(1);
	var people:ResultsList = store.query(Person).findAll();

Sometimes the data for the query hasn't been loaded yet. Calling `load()` will load the data for the query. The `load()` method will only load the data if it hasn't been loaded yet. Call `refresh()` if you want to force a reload of the data.

	// Load a query from the data source
	var guys:ResultsList = store.query(Person).where({sex:"m"}).load();

	// Reload the query
	guys.refresh();

The load operation for each query can be used to lnow when the data has finished loading. Add the event listener before calling `load()`. This ensures the listener exists for synchronous data calls.

	// Listening for loaded data
	person = store.query(Person).find(1);
	person.loadOperation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
	{
		trace("loaded " + person)
	});
	person.load();

Filtered queries can be used for returning records that match certain criteria.

	// Filtered queries
	var guys:ResultsList = store.query(Person).where({sex:"male"});

Query results automatically update whenever the store is updated. For result sets, you cannot add or remove elements directly from the result list. These operations must happen through the store.

	// Query for everyone
	var people:ResultsList = store.query(Person).findAll();
	trace(people.length); // 5

	// Remove a person from the store
	var person:Person = store.query(Person).find(1);
	person.remove();
	trace(people.length); // 4

### Data Source
The data source is used to connect the store to your backend. It defines a set of methods that your application must implement in order to create, retrieve, delete, and update data on the server.

**Example:** A sample data source.

	package myapp
	{
		public class MyDataSource extends AMFDataSource
		{
			public function MyDataSource()
			{
				super();
			}

			public function retrieve(recordType:Class, id:Object):Operation
			{
				return createOperation("retrieve", id)
			}
		}
	}

It's likely that an application will have many types of model classes, each with their own service endpoints. In these scenarios, a `MultiDataSource` can be used to map a record type to its own data source.

	// Map a data source to each type of record.
	var dataSource:MultiDataSource = new MultiDataSource();
	dataSource.map(Customer, new CustomerDataSource());
	dataSource.map(Account, new AccountDataSource());
	dataSource.map(Order, new OrderDataSource()); 

	var store:Store = new Store(dataSource);

## Records
Model classes in Mesh are sub-classes of `Record`. They define the relationships with other records, and watch how you application modifies them. They detect when their properties change, when their destroyed, and when their data is persisted to the backend. All records that are created and retrieved from your backend are kept in the store.

**Example:** A simple model.

	package myapp
	{
		[Bindable]
		public class Person extends Record
		{
			public var name:String;
			public var age:int;
		}
	}

### Associations
Records can have has-one and has-many relationships with other records. These relationships automatically update when the store changes.

When a record is associated, the necessary foreign keys are automatically populated, and the record is inserted into the store that contains the association.

**Example:** Definining Associations

	package myapp
	{
		[Bindable]
		public class Customer extends Record
		{
			public var name:String;
			public var age:int;

			public var accountId:int;

			[HasOne]
			public var account:Account;

			[HasMany(inverse="customer", recordType="myapp.Order")]
			public var orders:HasManyAssociation;

			public function Customer()
			{
				super();
			}
		}
	}

#### Has-one Associations
Has-one relationships are populated when the record's foreign keys change. If the associated record has not been loaded, an empty record will be created with its ID populated with the foreign key. The has-one association can then be loaded like so: `customer.account.load();`.

**Example:** Associating has-one relationships

	var customer:Customer = store.query(Customer).find(1);
	var account:Account = store.query(Account).find(2);
	customer.account = account;
	trace(account.customerId); // 1
	trace(customer.accountId); // 2

#### Has-many Associations
Has-many associations are populated through a call to load, like so: `customer.orders.load();`.

**Example:** Associating has-many relationships

	var order:Order = store.query(Order).find(3);
	customer.orders.add(order);
	trace(order.customerId); // 1

### Creating Records
The store is responsbile for creating new records in your application. These records will be persisted to the backend on the store's next save.

	var customer:Customer = store.create(Customer);

## Persisting Changes
The store's `commit()` method is responsible for saving changes to the backend. When `commit()` is called, a serialized commit is created that contains all the records that need to be created, updated, and destroyed on the backend. Each commit is then pushed into a queue to be persisted to the data source.

**Example:** Committing changes.

	// Save all changes.
	var commit:Commit = records.commit();

	// Save a subset of changes.
	commit = records.commit(person1, person2);

	trace(records.commits.length); // 2

### Commit Events
Your application can listen to the progress of the commit queue.

	// A commit is in the process of being persisted.
	store.commits.addEventListener(CommitQueueEvent.BUSY, function(event:CommitQueueEvent):void
	{
		trace("a commit started");
	});
	
	// All commits finished.
	store.commits.addEventListener(CommitQueueEvent.FINISH, function(event:CommitQueueEvent):void
	{
		trace("the commit queue is empty");
	});

	// A commit failed.
	store.commits.addEventListener(CommitFailedEvent.FAILED, function(event:CommitFailedEvent):void
	{
		trace("a commit failed");
	});

### Reverting a Failed Commit
If a commit fails to persist, you can choose to revert the store to a state before the commit failed.

	var customer:Customer = store.query(Customer).find(1);
	trace(customer.name); // John Doe
	customer.name = null; // Assume that the DB enforces that customers have a name.

	// A commit failed.
	store.commits.addEventListener(CommitFailedEvent.FAILED, function(event:CommitFailedEvent):void
	{
		trace("reverting commit");
		event.commit.revert();
		trace(customer.name); // John Doe
	});

	store.commit();
