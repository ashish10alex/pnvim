echo "-- $(date)" > /tmp/temp.sqlx
dataform compile --json | jq --arg tag "HOLDS" -r '.tables[] | select(.tags | any(. == $tag)) | "--" + .fileName + "\n" + .query + "; \n" '  >> /tmp/temp.sqlx ;
dataform compile --json | jq --arg tag "HOLDS" -r '.assertions[] | select(.tags | any(. == $tag)) | "--" + .fileName + "\n" + .query + "; \n" ' >> /tmp/temp.sqlx

