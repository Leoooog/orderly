/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2536031558")

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2382559930",
    "hidden": false,
    "id": "relation3612661072",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "menu_item",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2536031558")

  // remove field
  collection.fields.removeById("relation3612661072")

  return app.save(collection)
})
