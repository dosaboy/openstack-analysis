# default logging formats
# instance_uuid_format           = [instance: %(uuid)s]
# log_date_format                = %Y-%m-%d %H:%M:%S
# logging_user_identity_format   = %(user)s %(project)s %(domain)s %(user_domain)s %(project_domain)s
# logging_context_format_string  = %(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s
# logging_default_format_string  = %(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s
EXPR_UUID='[0-9a-z-]+'

EXPR_LOG_INSTANCE_UUID="\[instance: $EXPR_UUID\]"
EXPR_LOG_INSTANCE_UUID_GROUP_UUID="\[instance: ($EXPR_UUID)\]"
EXPR_LOG_INSTANCE_UUID_INSERT_UUID="\[instance: \${INSERT}\]"

EXPR_LOG_DATE='[0-9-]+ [0-9:]+\.[0-9]+'
EXPR_LOG_DATE_GROUP_TIME='[0-9-]+ ([0-9:]+)\.[0-9]+'
EXPR_LOG_DATE_GROUP_DATE_AND_TIME='([0-9-]+) ([0-9:]+)\.[0-9]+'

EXPR_LOG_CONTEXT="[0-9]+ [A-Z]+ $LOG_MODULE \[req-$EXPR_UUID $EXPR_UUID $EXPR_UUID $EXPR_UUID $EXPR_UUID $EXPR_UUID\]"

EXPR_LOG_CONTEXT_GROUP_USER="[0-9]+ [A-Z]+ $LOG_MODULE \[req-$EXPR_UUID ($EXPR_UUID) $EXPR_UUID $EXPR_UUID $EXPR_UUID $EXPR_UUID\]"
EXPR_LOG_CONTEXT_INSERT_USER="[0-9]+ [A-Z]+ $LOG_MODULE \[req-$EXPR_UUID \$INSERT $EXPR_UUID $EXPR_UUID $EXPR_UUID $EXPR_UUID\]"

EXPR_LOG_CONTEXT_GROUP_REQ="[0-9]+ [A-Z]+ $LOG_MODULE \[req-($EXPR_UUID) $EXPR_UUID $EXPR_UUID $EXPR_UUID $EXPR_UUID $EXPR_UUID\]"
EXPR_LOG_CONTEXT_INSERT_REQ="[0-9]+ [A-Z]+ $LOG_MODULE \[req-\$INSERT $EXPR_UUID $EXPR_UUID $EXPR_UUID $EXPR_UUID $EXPR_UUID\]"
