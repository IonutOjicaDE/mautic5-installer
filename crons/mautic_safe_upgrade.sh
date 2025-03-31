#!/bin/bash

# --------------------------
# Mautic Safe Upgrade & Rollback Tool v3 (Polish)
# --------------------------
# Argumente:
#   $1 = Cale absoluta spre Mautic
#   $2 = Versiune (ex: 6.0.0) SAU rollback | undo | revert | previous
#   $3 = (optional) dry-run
# --------------------------

# === CONFIG ===
WWW_USER="www-data"
PERM_DIRS=("var" "media" "cache" "logs")
REQUIRED_SPACE_MB=500

# === Dry-run detect ===
if [[ "$*" =~ "dry-run" ]]; then
    DRY='echo ['$(date +%Y-%m-%d_%H:%M:%S)']   MAUTIC UPGRADE   🚧   [ '
    DRY2=' ]'
    DRY_RUN="yes"
else
    DRY=""
    DRY2=""
    DRY_RUN="no"
fi

# === Argumente ===
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "❌ Utilizare: $0 <cale_mautic> <versiune|rollback> [dry-run]"
    exit 1
fi

MAUTIC_DIR=$(realpath "$1")
ACTION="$2"

# === Logging avansat ===
function log() {
    local ICON="$1"
    shift
    echo "[$(date +%Y-%m-%d_%H:%M:%S)]   MAUTIC UPGRADE   $ICON   $*" | tee -a "$LOGFILE"
}

function error_exit() {
    log "⛔" "$1"
    if [ "$ACTION" != "rollback" ]; then
        rollback
    fi
    exit 1
}

# === Pre-flight ===
LOGFILE="$MAUTIC_DIR/mautic_upgrade_$(date +'%Y%m%d_%H%M%S').log"

if [ ! -f "$MAUTIC_DIR/app/config/local.php" ]; then
    echo "❌ Nu am gasit local.php in $MAUTIC_DIR"
    exit 1
fi

if [ ! -d "$MAUTIC_DIR/backups" ]; then
    mkdir -p "$MAUTIC_DIR/backups"
    log "⚠️" "Am creat folderul backups/"
fi

FREE_SPACE=$(df -Pm "$MAUTIC_DIR" | awk 'NR==2 {print $4}')
if [ "$FREE_SPACE" -lt "$REQUIRED_SPACE_MB" ]; then
    error_exit "Spatiu liber insuficient (${FREE_SPACE}MB < ${REQUIRED_SPACE_MB}MB)"
fi

log "✅" "Pre-flight check OK - spatiu liber: ${FREE_SPACE}MB"

# === Citire baza de date ===
DB_NAME=$(grep "'db_name'" "$MAUTIC_DIR/app/config/local.php" | awk -F"'" '{print $4}')
DB_USER=$(grep "'db_user'" "$MAUTIC_DIR/app/config/local.php" | awk -F"'" '{print $4}')
DB_PASS=$(grep "'db_password'" "$MAUTIC_DIR/app/config/local.php" | awk -F"'" '{print $4}')
DB_HOST=$(grep "'db_host'" "$MAUTIC_DIR/app/config/local.php" | awk -F"'" '{print $4}')

cd "$MAUTIC_DIR" || exit 1
CURRENT_VERSION=$(php bin/console --version | grep -oP '\d+\.\d+\.\d+')

# === Functii utile ===

function fix_permissions() {
    log "🔄" "Setare permisiuni"
    for dir in "${PERM_DIRS[@]}"; do
        if [ -d "$MAUTIC_DIR/$dir" ]; then
            $DRY chmod -R 755 "$MAUTIC_DIR/$dir" $DRY2
            $DRY chown -R $WWW_USER:$WWW_USER "$MAUTIC_DIR/$dir" $DRY2
        fi
    done
    log "✅" "Permisiuni aplicate"
}

function do_backup() {
    BACKUP_DIR="$MAUTIC_DIR/backups/backup_${CURRENT_VERSION}_$(date +'%Y%m%d_%H%M%S')"
    $DRY mkdir -p "$BACKUP_DIR" $DRY2

    $DRY cp composer.json composer.lock "$BACKUP_DIR/" $DRY2
    $DRY mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_DIR/db.sql" $DRY2

    log "✅" "Backup salvat in $BACKUP_DIR"
}

function rollback() {
    log "🔄" "Rollback pornit"
    LAST_BACKUP=$(ls -d "$MAUTIC_DIR/backups/"*/ | sort | tail -n1)
    if [ ! -d "$LAST_BACKUP" ]; then
        log "❌" "Backup inexistent!"
        return
    fi

    $DRY cp "$LAST_BACKUP/composer.json" composer.json $DRY2
    $DRY cp "$LAST_BACKUP/composer.lock" composer.lock $DRY2
    $DRY mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$LAST_BACKUP/db.sql" $DRY2
    $DRY php bin/console cache:clear $DRY2

    log "✅" "Rollback finalizat din: $LAST_BACKUP"
}

function upgrade() {
    $DRY sed -i "s/\"mautic\/core\": \".*\"/\"mautic\/core\": \"^${VERSION_MAJOR}\"/" composer.json $DRY2

    $DRY composer update --with-all-dependencies $DRY2
    $DRY php bin/console cache:clear $DRY2
    $DRY php bin/console doctrine:migration:migrate --no-interaction $DRY2
    $DRY php bin/console mautic:update:apply --finish $DRY2
    $DRY php bin/console cache:clear $DRY2
}

# === EXECUTIE ===

log "🔄" "Mautic detectat in: $MAUTIC_DIR"
log "🔄" "Versiune curenta: $CURRENT_VERSION"

fix_permissions

if [[ "$ACTION" =~ ^(rollback|revert|undo|previous)$ ]]; then
    rollback
    log "✅" "Rollback finalizat complet"
    exit 0
fi

VERSION_PATTERN='^[0-9]+\.[0-9]+\.[0-9]+$'
if [[ ! "$ACTION" =~ $VERSION_PATTERN ]]; then
    error_exit "Versiune invalida (ex: 6.0.0)"
fi

VERSION_MAJOR=$(echo "$ACTION" | cut -d. -f1)

if [ "$ACTION" == "$CURRENT_VERSION" ]; then
    error_exit "Versiunea este deja instalata."
fi

STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://github.com/mautic/mautic/releases/tag/$ACTION")
if [ "$STATUS" -ne 200 ]; then
    error_exit "Versiunea $ACTION nu a fost gasita pe GitHub."
fi

log "✅" "Versiune target gasita pe GitHub: $ACTION"

do_backup
upgrade
fix_permissions

log "✅" "Upgrade complet la Mautic $ACTION"
log "=== Script terminat ==="
