/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2382559930")

  // add field
  collection.fields.addAt(9, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_3865025440",
    "hidden": false,
    "id": "relation2083972527",
    "maxSelect": 999,
    "minSelect": 0,
    "name": "produced_by",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2382559930")

  // remove field
  collection.fields.removeById("relation2083972527")

  return app.save(collection)
})
