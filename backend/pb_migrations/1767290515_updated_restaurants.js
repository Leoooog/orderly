/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1567773776")

  // update field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1579384326",
    "max": 0,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // update field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text223244161",
    "max": 0,
    "min": 0,
    "name": "address",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // update field
  collection.fields.addAt(3, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text2299572365",
    "max": 0,
    "min": 0,
    "name": "vat_number",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // update field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "select1098958488",
    "maxSelect": 1,
    "name": "locale",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "it_IT",
      "en_EN"
    ]
  }))

  // update field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "select1213075606",
    "maxSelect": 1,
    "name": "currency_symbol",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "€",
      "£",
      "$"
    ]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1567773776")

  // update field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1579384326",
    "max": 0,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // update field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text223244161",
    "max": 0,
    "min": 0,
    "name": "address",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // update field
  collection.fields.addAt(3, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text2299572365",
    "max": 0,
    "min": 0,
    "name": "vat_number",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // update field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "select1098958488",
    "maxSelect": 1,
    "name": "locale",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "it_IT",
      "en_EN"
    ]
  }))

  // update field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "select1213075606",
    "maxSelect": 1,
    "name": "currency_symbol",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "€",
      "£",
      "$"
    ]
  }))

  return app.save(collection)
})
