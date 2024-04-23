#!/usr/bin/env nu
use grist.nu

let mail_table = $env.MAIL_TABLE | str capitalize
let columns_schema = open columns_schema.json 
let table_schema = {
  "tables": [
    {
      "id": $mail_table,
      "label": $mail_table,
      "columns": $columns_schema
    }
  ]
}

grist ensure_table $mail_table $table_schema

let messages = grist records $mail_table {"sent": [""]}
for msg in $messages.records {
  (curl --ssl-reqd --url "smtps://smtp.numerique.gouv.fr"
    --user $"($env.MAIL_USER):($env.MAIL_PASSWORD)"
    --mail-from $"($env.MAIL_USER)" 
    --mail-rcpt $"($msg.fields.recipients)" 
    --header $"Subject: ($msg.fields.subject)" 
    --header $"From: ($env.MAIL_USER)" 
    --header $"To: ($msg.fields.recipients)" 
    --form '=(;type=multipart/mixed' 
    --form $"=($msg.fields.message);type=text/plain" 
    --form '=)')
  let $now = date now|format date "%Y-%m-%d %H:%M:%S"
  grist patch $mail_table [{"id": $msg.id, "fields": {"sent": $now}}]
}
