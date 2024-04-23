# send-nudes
nushell script sending mail.

## what is send-nudes ? 
An email is sent for each line you add in the send-nudes grist table. 
send-nudes:
- can run on premise or github actions
- is able to throttle mail delivery
- is dead simple

## how do I use send-nudes ?
1. Fork this repository
2. Choose a nice unused name for your grist table
3. Set your repository secrets (see requirements below) 
4. Tweak and activate your workflow, your send-nudes table is created on first run 
5. Add lines in your new table 
6. Repeat until it's of no use

## configuration
### on-premise
- install nushell & curl
- set secrets and parameters as environment variables
- execute `nu send-nudes.nu`
- …
- profit

### github actions
- set secrets and parameters as repository secrets
- enable the nu.yml workflow 
- …
- profit

### secrets
| Secret            | Nature                      | Example                     |
| ----------------- | --------------------------- | --------------------------- |
| `GRIST_APIKEY`    | grist api key               | `no_its_not_real`           |
| `GRIST_ORG`       | grist organization          | `Personal`                  |
| `GRIST_WORKSPACE` | grist workspace             | `Home`                      |
| `GRIST_HOSTNAME`  | grist instance hostname     | `grist.example.com`         |
| `GRIST_DOC`       | name of your grist document | `paperclips and stamps ERP` |
| `MAIL_SMTP`       | your smtp url               | `smtps://smtp.example.com`  |
| `MAIL_SENDER`     | your sender identity        | `john.doe@example.com`      | 
| `MAIL_USER`       | your sender smtp username   | `john.doe`                  |
| `MAIL_PASSWORD`   | your sender password        | `who_am_i_?`                |
| `MAIL_TABLE`      | the name of dedicated table | `send_nudes_database`       |


