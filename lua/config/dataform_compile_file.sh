echo "-- $(date)" > /tmp/temp.sqlx
dataform compile --json | jq --arg tag "DPR" -r '.tables[] | select(.tags | any(. == $tag)) | select( .fileName == "definitions/0200_D42_EVENTS_META_DATA.sqlx")' >> /private/tmp/temp.sqlx ;
dataform compile --json | jq --arg tag "DPR" -r '.assertions[] | select(.tags | any(. == $tag)) | select( .fileName == "definitions/0200_D42_EVENTS_META_DATA.sqlx")' >> /private/tmp/temp.sqlx ;
