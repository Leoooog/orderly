/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2536031558")

  // add field
  collection.fields.addAt(11, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2456927940",
    "hidden": false,
    "id": "relation1391075081",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "order_item",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2536031558")

  // remove field
  collection.fields.removeById("relation1391075081")

  return app.save(collection)
})
