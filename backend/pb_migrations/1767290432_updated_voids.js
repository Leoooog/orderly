/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2536031558")

  // update field
  collection.fields.addAt(6, new Field({
    "hidden": false,
    "id": "select3787507523",
    "maxSelect": 1,
    "name": "status_when_voided",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "pending",
      "fired",
      "cooking",
      "ready",
      "served"
    ]
  }))

  // update field
  collection.fields.addAt(8, new Field({
    "cascadeDelete": false,
    "collectionId": "_pb_users_auth_",
    "hidden": false,
    "id": "relation492071365",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "voided_by",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  // update field
  collection.fields.addAt(9, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_193084973",
    "hidden": false,
    "id": "relation1001949196",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "reason",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2536031558")

  // update field
  collection.fields.addAt(6, new Field({
    "hidden": false,
    "id": "select3787507523",
    "maxSelect": 1,
    "name": "status_when_voided",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "pending",
      "fired",
      "cooking",
      "ready",
      "served"
    ]
  }))

  // update field
  collection.fields.addAt(8, new Field({
    "cascadeDelete": false,
    "collectionId": "_pb_users_auth_",
    "hidden": false,
    "id": "relation492071365",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "voided_by",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // update field
  collection.fields.addAt(9, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_193084973",
    "hidden": false,
    "id": "relation1001949196",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "reason",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
})
