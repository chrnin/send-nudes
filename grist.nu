#!/usr/bin/env nu

def init_grist [] {
    if  not (["GRIST_APIKEY", "GRIST_ORG", "GRIST_WORKSPACE", "GRIST_DOC", "GRIST_DOMAIN"]|all {|c| $c in ($env|columns)}) {
        echo "error: env is not set (see .env.example)"
        exit 1
    }    

    let apikey = ['Authorization', $'Bearer ($env.GRIST_APIKEY)']

    # organisations
    let organisations = http get --headers $apikey $"https://($env.GRIST_DOMAIN)/api/orgs"
    let org_id = try { $organisations | where name == $env.GRIST_ORG |get "id" | get 0 } catch { null }
    if $org_id == null {
      print $"organisation not found: ($env.GRIST_ORG), see available organisations below:"
      print $organisations 
      return null
    }
    
    # workspace
    let workspaces = http get --headers $apikey $"https://($env.GRIST_DOMAIN)/api/orgs/($org_id)/workspaces"
    let workspace_id = try {$workspaces|where name == $env.GRIST_WORKSPACE|get "id"|get 0} catch { null }
    if $workspace_id == null {
        print $"workspace not mound: ($env.GRIST_WORKSPACE), see available workspace below:"
        print $workspaces 
    }

    # document
    let doc_id = http get --headers $apikey $"https://($env.GRIST_DOMAIN)/api/workspaces/($workspace_id)" |get "docs"|get "id"|get 0
    let tables = http get --headers $apikey $"https://($env.GRIST_DOMAIN)/api/docs/($doc_id)/tables"
    let grist = {
       apikey: $apikey,
       org_id: $org_id,
       workspace_id: $workspace_id,
       doc_id: $doc_id,
       tables: $tables.tables,
    }
    return $grist
}

export-env {
    let grist_object = init_grist
    $env.GRIST = $grist_object
}

def grist_url [] { $"https://($env.GRIST_DOMAIN)/api" }

export def document_url [] {
    return $"(grist_url)/docs/($env.GRIST.doc_id)" 
}

export def table_url [table_name: string] {
    return $"(document_url)/tables/($table_name)"
}

export def record_url [table_name: string] {
    return $"(table_url $table_name)/records"
}

export def env [] {
    return $env.GRIST
}

export def records [table_name: string, params: any] {
    let record_url = record_url $table_name
    let filter = $"?filter=($params|to json|url encode)"
    let url = $"($record_url)($filter)"
    return (http get --headers $env.GRIST.apikey $url)
}

export def patch [table_name: string, records: list<record>] {
    let url = record_url $table_name
    let payload = {"records": $records}
    http patch --raw --content-type application/json --headers $env.GRIST.apikey $url $payload
}

export def ensure_table [table_name: string, table_schema: any] {
    print $env.GRIST.tables.id
    print $env.MAIL_TABLE
    if ($table_name |str capitalize) in $env.GRIST.tables.id {
        print $"table ($table_name) exists"
        # TODO: check schema 
    } else {
        print $"creating table ($table_name) doesn't exist"
	http post --content-type application/json --headers $env.GRIST.apikey $"(document_url)/tables" $table_schema
    }
}

