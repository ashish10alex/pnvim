echo "-- $(date)" > /tmp/temp.sqlx
dataform compile --json | jq -r '.tables | map("-- \(.fileName)\n-- \(.tags)\n\(.query) ;") | join("\n")'  >> /private/tmp/temp.sqlx ;
dataform compile --json | jq -r '.assertions | map("-- \(.fileName)\n-- \(.tags)\n\(.query) ;") | join("\n")'  >>  /private/tmp/temp.sqlx;
