package mesh.services
{
	import flash.utils.flash_proxy;
	
	import mesh.model.Entity;
	import mesh.model.associations.Association;
	
	use namespace flash_proxy;
	
	public class AutoSaveRequest extends Request
	{
		private var _entities:Array;
		private var _propertyToEntities:Object = {};
		
		public function AutoSaveRequest(entities:Array)
		{
			_entities = entities;
			super(save);
		}
		
		private function gatherAutoSaveAssociations():AutoSaveAssociations
		{
			var associations:AutoSaveAssociations = new AutoSaveAssociations();
			for each (var entity:Entity in _entities) {
				for each (var association:Association in entity.associations) {
					if (association.definition.autoSave) {
						associations.add(association);
					}
				}
			}
			return associations;
		}
		
		private function save():void
		{
			gatherAutoSaveAssociations().save().execute({fault:fault, success:success});
		}
	}
}

import collections.HashMap;

import flash.utils.flash_proxy;

import mesh.Mesh;
import mesh.core.array.flatten;
import mesh.model.associations.Association;
import mesh.services.Request;

use namespace flash_proxy;

class AutoSaveAssociations extends HashMap
{
	public function AutoSaveAssociations()
	{
		super();
	}
	
	public function add(association:Association):void
	{
		if (association.definition.autoSave) {
			var property:String = association.definition.property;
			if (!containsKey(property)) {
				put(property, []);
			}
			grab(property).push(association);
		}
	}
	
	private function createSaveRequest(associations:Array):Request
	{
		var entities:Array = gatherEntitiesFromAssociations(associations);
		return (entities.length > 0) ? Mesh.service(entities[0].reflect.clazz).save(entities) : new Request();
	}
	
	private function gatherEntitiesFromAssociations(associations:Array):Array
	{
		var result:Array = [];
		for each (var association:Association in associations) {
			if (association.isDirty) {
				result = result.concat(association.dirtyEntities);
			}
		}
		return flatten(result);
	}
	
	public function save():Request
	{
		var request:Request = new Request();
		for each (var key:String in keys()) {
			request = request.and(createSaveRequest(grab(key)));
		}
		return request;
	}
}