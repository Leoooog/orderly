/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2382559930")

  // add field
  collection.fields.addAt(4, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_3292755704",
    "hidden": false,
    "id": "relation105650625",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "category",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "bool2725759466",
    "name": "is_available",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // add field
  collection.fields.addAt(6, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_3146854971",
    "hidden": false,
    "id": "relation1264587087",
    "maxSelect": 999,
    "minSelect": 0,
    "name": "ingredients",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(7, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_64780588",
    "hidden": false,
    "id": "relation1744281524",
    "maxSelect": 999,
    "minSelect": 0,
    "name": "allergens",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(8, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_294131871",
    "hidden": false,
    "id": "relation2924518957",
    "maxSelect": 999,
    "minSelect": 0,
    "name": "allowed_extras",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2382559930")

  // remove field
  collection.fields.removeById("relation105650625")

  // remove field
  collection.fields.removeById("bool2725759466")

  // remove field
  collection.fields.removeById("relation1264587087")

  // remove field
  collection.fields.removeById("relation1744281524")

  // remove field
  collection.fields.removeById("relation2924518957")

  return app.save(collection)
})
