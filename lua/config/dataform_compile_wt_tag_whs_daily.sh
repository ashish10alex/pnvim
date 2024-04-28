echo "-- $(date)" > /tmp/temp.sqlx
dataform compile --json | jq --arg tag "WHS_daily" -r '.tables[] | select(.tags | any(. == $tag)) | "-- } " + .fileName + "\n" + "-- { tags " + (.tags | tojson) + "\n" + .query + "; \n" '  >> /private/tmp/temp.sqlx ;
dataform compile --json | jq --arg tag "WHS_daily" -r '.assertions[] | select(.tags | any(. == $tag)) | "-- } " + .fileName + "\n" + "-- { tags " + (.tags | tojson) + "\n" + .query + "; \n" ' >> /private/tmp/temp.sqlx
