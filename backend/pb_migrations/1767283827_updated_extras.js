/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_294131871")

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "bool2725759466",
    "name": "is_available",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_294131871")

  // remove field
  collection.fields.removeById("bool2725759466")

  return app.save(collection)
})
