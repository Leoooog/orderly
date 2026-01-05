/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_631030571")

  // remove field
  collection.fields.removeById("number2212961265")

  // add field
  collection.fields.addAt(7, new Field({
    "hidden": false,
    "id": "bool2212961265",
    "name": "is_deposit",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_631030571")

  // add field
  collection.fields.addAt(7, new Field({
    "hidden": false,
    "id": "number2212961265",
    "max": null,
    "min": null,
    "name": "is_deposit",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  // remove field
  collection.fields.removeById("bool2212961265")

  return app.save(collection)
})
