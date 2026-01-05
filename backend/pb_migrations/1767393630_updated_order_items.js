/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2456927940")

  // add field
  collection.fields.addAt(12, new Field({
    "hidden": false,
    "id": "number339892878",
    "max": null,
    "min": null,
    "name": "price_each",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2456927940")

  // remove field
  collection.fields.removeById("number339892878")

  return app.save(collection)
})
