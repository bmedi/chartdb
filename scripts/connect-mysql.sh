#!/bin/bash

# ChartDB MySQL Connection Helper
# This script helps you connect to your local MySQL database and export schema for ChartDB

# Configuration - Update these values for your database
DB_HOST="localhost"
DB_PORT="3306"
DB_NAME="your_database_name"
DB_USER="your_username"
# DB_PASSWORD="your_password"  # Uncomment and set if needed

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ChartDB MySQL Connection Helper${NC}"
echo "=================================="
echo ""

# Check if mysql is available
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ mysql command not found. Please install MySQL client tools.${NC}"
    echo "   On macOS: brew install mysql-client"
    echo "   On Ubuntu: sudo apt-get install mysql-client"
    echo "   On Windows: Download from https://dev.mysql.com/downloads/"
    exit 1
fi

# Test connection
echo -e "${YELLOW}🔍 Testing connection to MySQL...${NC}"
if mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SELECT 1;" &> /dev/null; then
    echo -e "${GREEN}✅ Connection successful!${NC}"
else
    echo -e "${RED}❌ Connection failed. Please check your settings:${NC}"
    echo "   Host: $DB_HOST"
    echo "   Port: $DB_PORT"
    echo "   Database: $DB_NAME"
    echo "   User: $DB_USER"
    echo ""
    echo "Common solutions:"
    echo "   - Make sure MySQL is running"
    echo "   - Check if the database exists"
    echo "   - Verify username and password"
    echo "   - Check firewall settings"
    exit 1
fi

echo ""
echo -e "${YELLOW}📊 Exporting database schema for ChartDB...${NC}"

# Create the ChartDB Smart Query for MySQL
QUERY='
SELECT CONCAT(
    '"'"'{"fk_info": [', COALESCE(fk_metadata, '"'"'""'"'"'),
    '"], "pk_info": [', COALESCE(pk_metadata, '"'"'""'"'"'),
    '"], "columns": [', COALESCE(cols_metadata, '"'"'""'"'"'),
    '"], "indexes": [', COALESCE(indexes_metadata, '"'"'""'"'"'),
    '"], "tables":[', COALESCE(tbls_metadata, '"'"'""'"'"'),
    '"], "views":[', COALESCE(views_metadata, '"'"'""'"'"'),
    '"], "database_name": "', DATABASE(), '", "version": "', VERSION(), '"}'
) AS metadata_json_to_import
FROM (
    SELECT 
        GROUP_CONCAT(
            CONCAT(
                '"'"'{"schema":"', TABLE_SCHEMA, '"',
                ',"table":"', TABLE_NAME, '"',
                ',"column":"', COLUMN_NAME, '"',
                ',"foreign_key_name":"', CONSTRAINT_NAME, '"',
                ',"reference_schema":"', REFERENCED_TABLE_SCHEMA, '"',
                ',"reference_table":"', REFERENCED_TABLE_NAME, '"',
                ',"reference_column":"', REFERENCED_COLUMN_NAME, '"',
                ',"fk_def":""}'
            ) SEPARATOR '"'"', '"'"'
        ) AS fk_metadata
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE REFERENCED_TABLE_NAME IS NOT NULL
      AND TABLE_SCHEMA NOT IN ('"'"'information_schema'"'"', '"'"'mysql'"'"', '"'"'performance_schema'"'"', '"'"'sys'"'"')
) AS fk_info,
(
    SELECT 
        GROUP_CONCAT(
            CONCAT(
                '"'"'{"schema":"', TABLE_SCHEMA, '"',
                ',"table":"', TABLE_NAME, '"',
                ',"column":"', COLUMN_NAME, '"',
                '}'
            ) SEPARATOR '"'"', '"'"'
        ) AS pk_metadata
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE CONSTRAINT_NAME = '"'"'PRIMARY'"'"'
      AND TABLE_SCHEMA NOT IN ('"'"'information_schema'"'"', '"'"'mysql'"'"', '"'"'performance_schema'"'"', '"'"'sys'"'"')
) AS pk_info,
(
    SELECT 
        GROUP_CONCAT(
            CONCAT(
                '"'"'{"schema":"', TABLE_SCHEMA, '"',
                ',"table":"', TABLE_NAME, '"',
                ',"column":"', COLUMN_NAME, '"',
                ',"type":"', DATA_TYPE, '"',
                ',"nullable":"', IS_NULLABLE, '"',
                ',"default":"', COALESCE(COLUMN_DEFAULT, '"'"'""'"'"'), '"',
                ',"comment":"', COALESCE(COLUMN_COMMENT, '"'"'""'"'"'), '"',
                '}'
            ) SEPARATOR '"'"', '"'"'
        ) AS cols_metadata
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA NOT IN ('"'"'information_schema'"'"', '"'"'mysql'"'"', '"'"'performance_schema'"'"', '"'"'sys'"'"')
) AS cols,
(
    SELECT 
        GROUP_CONCAT(
            CONCAT(
                '"'"'{"schema":"', TABLE_SCHEMA, '"',
                ',"table":"', TABLE_NAME, '"',
                ',"index":"', INDEX_NAME, '"',
                ',"columns":"', GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX), '"',
                ',"unique":"', CASE WHEN NON_UNIQUE = 0 THEN '"'"'true'"'"' ELSE '"'"'false'"'"' END, '"',
                '}'
            ) SEPARATOR '"'"', '"'"'
        ) AS indexes_metadata
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA NOT IN ('"'"'information_schema'"'"', '"'"'mysql'"'"', '"'"'performance_schema'"'"', '"'"'sys'"'"')
    GROUP BY TABLE_SCHEMA, TABLE_NAME, INDEX_NAME
) AS indexes_metadata,
(
    SELECT 
        GROUP_CONCAT(
            CONCAT(
                '"'"'{"schema":"', TABLE_SCHEMA, '"',
                ',"table":"', TABLE_NAME, '"',
                ',"rows":0, "type":"', TABLE_TYPE, '"',
                ',"engine":"', COALESCE(ENGINE, '"'"'""'"'"'), '"',
                ',"collation":"', COALESCE(TABLE_COLLATION, '"'"'""'"'"'), '"',
                ',"comment":"', COALESCE(TABLE_COMMENT, '"'"'""'"'"'), '"',
                '}'
            ) SEPARATOR '"'"', '"'"'
        ) AS tbls_metadata
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA NOT IN ('"'"'information_schema'"'"', '"'"'mysql'"'"', '"'"'performance_schema'"'"', '"'"'sys'"'"')
) AS tbls,
(
    SELECT 
        GROUP_CONCAT(
            CONCAT(
                '"'"'{"schema":"', TABLE_SCHEMA, '"',
                ',"view_name":"', TABLE_NAME, '"',
                ',"view_definition":"', COALESCE(VIEW_DEFINITION, '"'"'""'"'"'), '"',
                '}'
            ) SEPARATOR '"'"', '"'"'
        ) AS views_metadata
    FROM information_schema.VIEWS
    WHERE TABLE_SCHEMA NOT IN ('"'"'information_schema'"'"', '"'"'mysql'"'"', '"'"'performance_schema'"'"', '"'"'sys'"'"')
) AS views;
'

# Execute the query and save to file
OUTPUT_FILE="chartdb_mysql_schema_export.json"

if mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "$QUERY" > $OUTPUT_FILE; then
    echo -e "${GREEN}✅ Schema exported successfully to $OUTPUT_FILE${NC}"
    echo ""
    echo -e "${BLUE}📋 Next steps:${NC}"
    echo "1. Open ChartDB at http://localhost:8081"
    echo "2. Create a new diagram or open an existing one"
    echo "3. Click 'Import Database' from the sidebar"
    echo "4. Select 'MySQL' as the database type"
    echo "5. Choose 'Smart Query' as the import method"
    echo "6. Copy the contents of $OUTPUT_FILE into the text area"
    echo "7. Click 'Import'"
    echo ""
    echo -e "${YELLOW}💡 Tip: You can also run this script anytime to update your schema in ChartDB${NC}"
else
    echo -e "${RED}❌ Failed to export schema. Please check your database connection and permissions.${NC}"
    exit 1
fi
