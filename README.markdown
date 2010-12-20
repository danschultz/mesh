# Mesh
Mesh is an open-source persistence framework for [[Adobe Flex|http://www.adobe.com/products/flex/]]. It is designed to make the persistence of your application's model easier.

## Getting Started

### [[Installation|https://github.com/danschultz/mesh/wiki/installation]]
How to install and setup Mesh in your application.

## Entities
An entity is the base for your models in a Mesh application. Entities define the relationships with other entities, provide basic CRUD functionality, define validations, and tracks the changes that your application makes to them.

### [[Associations|https://github.com/danschultz/mesh/wiki/associations]]
How associations define the relationships between your entities.

### [[Aggregates]]
How aggregates help you fine-tune your model by grouping related properties into 
[[Value Objects|http://domaindrivendesign.org/node/135]].

### [[Validations]]
How validations are used to ensure that your data is valid before being persisted.

### [[Change Tracking]]
How Mesh knows which entities need to be persisted.

### [[Dynamic Entities]]
How dynamic entities reduce the amount of code you need to write.

## Service Adaptors
Service adaptors define how entities are persisted to your backend.  Mesh provides base classes for your service adaptors, but it is ultimately up to you to write the adaptors that will work with your application.

### [[Writing Service Adaptors]]
How service adaptors are used to map the creation, updating, destruction and retrieval of entities from your backend.

## Contributing

### [[Code and Patches]]
How to get your environment up and running, and start contributing code and patches to Mesh.