/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1567773776")

  // add field
  collection.fields.addAt(6, new Field({
    "hidden": false,
    "id": "number18729739",
    "max": null,
    "min": null,
    "name": "coverCharge",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  // add field
  collection.fields.addAt(7, new Field({
    "hidden": false,
    "id": "number3636168745",
    "max": null,
    "min": null,
    "name": "serviceFeePercent",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1567773776")

  // remove field
  collection.fields.removeById("number18729739")

  // remove field
  collection.fields.removeById("number3636168745")

  return app.save(collection)
})
