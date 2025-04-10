#!/bin/bash

###############################################################################################
#####                                 Initialize Mautic                                   #####
###############################################################################################


show_info ${ICON_INFO} 'Initialize Mautic...'

cat > "$MAUTIC_FOLDER/.env.local.php" <<EOF
<?php
return [
    'APP_ENV' => 'prod',
    'APP_SECRET' => '${MAUTIC_SECRET_KEY}',
    'MAUTIC_TABLE_PREFIX' => null,
    'INSTALL_SOURCE' => 'Composer',
    'DB_DRIVER' => 'pdo_mysql',
    'DB_HOST' => 'localhost',
    'DB_PORT' => '3306',
    'DB_NAME' => 'mautic${MAUTIC_COUNT}',
    'DB_USER' => 'mautic${MAUTIC_COUNT}',
    'DB_PASSWORD' => '${MYSQL_MAUTICUSER_PASSWORD}',
    'MAUTIC_ADMIN_USERNAME' => '${MAUTIC_USERNAME}',
    'MAUTIC_ADMIN_PASSWORD' => '${MAUTIC_ADMIN_PASSWORD}',
    'MAUTIC_ADMIN_EMAIL' => '${ADMIN_EMAIL}',
    'site_url' => 'https://${MAUTIC_SUBDOMAIN}',
];
EOF

runuser -u www-data -- php bin/console mautic:install

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
USE mautic${MAUTIC_COUNT};
UPDATE users
SET firstname='${SENDER_FIRSTNAME}',
    lastname='${SENDER_LASTNAME}',
    email='${SENDER_EMAIL}'
WHERE username='${MAUTIC_USERNAME}';
EOF

#mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
#USE mautic${MAUTIC_COUNT};
#INSERT INTO config (bundle, name, value) VALUES
#('CoreBundle', 'mailer_return_path', '"${SENDER_EMAIL}"')
#ON DUPLICATE KEY UPDATE value='"${SENDER_EMAIL}"';
#
#UPDATE email_settings
#SET name='${SENDER_FIRSTNAME} ${SENDER_LASTNAME}',
#    email='${SENDER_EMAIL}'
#WHERE is_default = 1;
#EOF

show_info ${ICON_OK} 'Mautic initialized.'

show_info ${ICON_INFO} 'Clearing cache...'
runuser -u www-data -- php "${CRON_FOLDER}cron-clear-cache.php"

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

show_info ${ICON_OK} 'Cache is cleared.'

