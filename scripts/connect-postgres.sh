#!/bin/bash

# ChartDB PostgreSQL Connection Helper
# This script helps you connect to your local PostgreSQL database and export schema for ChartDB

# Configuration - Update these values for your database
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="your_database_name"
DB_USER="your_username"
# DB_PASSWORD="your_password"  # Uncomment and set if needed

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ChartDB PostgreSQL Connection Helper${NC}"
echo "=================================="
echo ""

# Check if psql is available
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ psql command not found. Please install PostgreSQL client tools.${NC}"
    echo "   On macOS: brew install postgresql"
    echo "   On Ubuntu: sudo apt-get install postgresql-client"
    echo "   On Windows: Download from https://www.postgresql.org/download/"
    exit 1
fi

# Test connection
echo -e "${YELLOW}🔍 Testing connection to PostgreSQL...${NC}"
if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" &> /dev/null; then
    echo -e "${GREEN}✅ Connection successful!${NC}"
else
    echo -e "${RED}❌ Connection failed. Please check your settings:${NC}"
    echo "   Host: $DB_HOST"
    echo "   Port: $DB_PORT"
    echo "   Database: $DB_NAME"
    echo "   User: $DB_USER"
    echo ""
    echo "Common solutions:"
    echo "   - Make sure PostgreSQL is running"
    echo "   - Check if the database exists"
    echo "   - Verify username and password"
    echo "   - Check firewall settings"
    exit 1
fi

echo ""
echo -e "${YELLOW}📊 Exporting database schema for ChartDB...${NC}"

# Create the ChartDB Smart Query
# This is the same query that ChartDB provides, but we'll execute it directly
QUERY='
WITH fk_info AS (
    SELECT array_to_string(array_agg(CONCAT('"{"', '"', '"schema":"', replace(schema_name::TEXT, '"', ''), '"',
                                            ',"table":"', replace(table_name::TEXT, '"', ''), '"',
                                            ',"column":"', replace(fk_column::TEXT, '"', ''), '"',
                                            ',"foreign_key_name":"', foreign_key_name::TEXT, '"',
                                            ',"reference_schema":"', COALESCE(reference_schema::TEXT, 'public'), '"',
                                            ',"reference_table":"', reference_table::TEXT, '"',
                                            ',"reference_column":"', reference_column::TEXT, '"',
                                            ',"fk_def":"', replace(fk_def::TEXT, '"', ''),
                                            '"}')), ',') as fk_metadata
    FROM (
            SELECT c.conname AS foreign_key_name,
                    n.nspname AS schema_name,
                    CASE
                        WHEN position(''.'' in conrelid::regclass::text) > 0
                        THEN split_part(conrelid::regclass::text, ''.'', 2)
                        ELSE conrelid::regclass::text
                    END AS table_name,
                    a.attname AS fk_column,
                    nr.nspname AS reference_schema,
                    CASE
                        WHEN position(''.'' in confrelid::regclass::text) > 0
                        THEN split_part(confrelid::regclass::text, ''.'', 2)
                        ELSE confrelid::regclass::text
                    END AS reference_table,
                    af.attname AS reference_column,
                    pg_get_constraintdef(c.oid) as fk_def
                FROM
                    pg_constraint AS c
                JOIN
                    pg_attribute AS a ON a.attnum = ANY(c.conkey) AND a.attrelid = c.conrelid
                JOIN
                    pg_class AS cl ON cl.oid = c.conrelid
                JOIN
                    pg_namespace AS n ON n.oid = cl.relnamespace
                JOIN
                    pg_attribute AS af ON af.attnum = ANY(c.confkey) AND af.attrelid = c.confrelid
                JOIN
                    pg_class AS clf ON clf.oid = c.confrelid
                JOIN
                    pg_namespace AS nr ON nr.oid = clf.relnamespace
                WHERE
                    c.contype = '"'"'f'"'"'
                    AND connamespace::regnamespace::text NOT IN ('"'"'information_schema'"'"', '"'"'pg_catalog'"'"')
        ) AS fk
), pk_info AS (
    SELECT array_to_string(array_agg(CONCAT('"{"', '"', '"schema":"', replace(schema_name::TEXT, '"', ''), '"',
                                            ',"table":"', replace(table_name::TEXT, '"', ''), '"',
                                            ',"column":"', replace(column_name::TEXT, '"', ''), '"',
                                            '"}')), ',') as pk_metadata
    FROM (
            SELECT n.nspname AS schema_name,
                    CASE
                        WHEN position(''.'' in c.relname) > 0
                        THEN split_part(c.relname, ''.'', 2)
                        ELSE c.relname
                    END AS table_name,
                    a.attname AS column_name
                FROM pg_class c
                JOIN pg_namespace n ON n.oid = c.relnamespace
                JOIN pg_index i ON i.indrelid = c.oid
                JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = ANY(i.indkey)
                WHERE i.indisprimary
                  AND c.relkind = '"'"'r'"'"'
                  AND n.nspname NOT IN ('"'"'information_schema'"'"', '"'"'pg_catalog'"'"')
        ) AS pk
), cols AS (
    SELECT array_to_string(array_agg(CONCAT('"{"', '"', '"schema":"', replace(cols.table_schema::TEXT, '"', ''), '"',
                                            ',"table":"', replace(cols.table_name::TEXT, '"', ''), '"',
                                            ',"column":"', replace(cols.column_name::TEXT, '"', ''), '"',
                                            ',"type":"', replace(cols.data_type::TEXT, '"', ''), '"',
                                            ',"nullable":"', replace(cols.is_nullable::TEXT, '"', ''), '"',
                                            ',"default":"', COALESCE(replace(cols.column_default::TEXT, '"', ''), '""'),
                                            '","comment":"', COALESCE(replace(replace(dsc.description::TEXT, '"', '\\"'), '\\x', '\\\\x'), '""'),
                                            '"}')), ',') AS cols_metadata
        FROM information_schema.columns cols
        LEFT JOIN pg_catalog.pg_class c ON c.relname = cols.table_name
        JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
                                            AND n.nspname = cols.table_schema
        LEFT JOIN pg_catalog.pg_description dsc ON dsc.objoid = c.oid
                                                AND dsc.objsubid = cols.ordinal_position
        WHERE cols.table_schema NOT IN ('"'"'information_schema'"'"', '"'"'pg_catalog'"'"')
), indexes_metadata AS (
    SELECT array_to_string(array_agg(CONCAT('"{"', '"', '"schema":"', replace(schema_name::TEXT, '"', ''), '"',
                                            ',"table":"', replace(table_name::TEXT, '"', ''), '"',
                                            ',"index":"', replace(index_name::TEXT, '"', ''), '"',
                                            '","columns":"', replace(columns::TEXT, '"', ''), '"',
                                            '","unique":"', replace(is_unique::TEXT, '"', ''), '"',
                                            '"}')), ',') AS indexes_metadata
        FROM (
            SELECT
                n.nspname AS schema_name,
                t.relname AS table_name,
                i.relname AS index_name,
                string_agg(a.attname, '","' ORDER BY array_position(i.indkey, a.attnum)) AS columns,
                i.indisunique AS is_unique
            FROM pg_class i
            JOIN pg_index ix ON i.oid = ix.indexrelid
            JOIN pg_class t ON ix.indrelid = t.oid
            JOIN pg_namespace n ON t.relnamespace = n.oid
            JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
            WHERE n.nspname NOT IN ('"'"'information_schema'"'"', '"'"'pg_catalog'"'"')
            GROUP BY n.nspname, t.relname, i.relname, i.indisunique
        ) AS idx
), tbls AS (
    SELECT array_to_string(array_agg(CONCAT('"{"', '"', '"schema":"', tbls.TABLE_SCHEMA::TEXT, '"',
                        ',"table":"', tbls.TABLE_NAME::TEXT, '"',
                        ',"rows":', COALESCE((SELECT s.n_live_tup::TEXT
                                                FROM pg_stat_user_tables s
                                                WHERE tbls.TABLE_SCHEMA = s.schemaname AND tbls.TABLE_NAME = s.relname),
                                                '"'"'0'"'"'), ', "type":"', tbls.TABLE_TYPE::TEXT, '"', ', "engine":"", "collation":"",',
                        '"comment":"', COALESCE(replace(replace(dsc.description::TEXT, '"', '\\"'), '\\x', '\\\\x'), '""'),
                        '"}'
                )),
                ',') AS tbls_metadata
        FROM information_schema.tables tbls
        LEFT JOIN pg_catalog.pg_class c ON c.relname = tbls.TABLE_NAME
        JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
                                            AND n.nspname = tbls.TABLE_SCHEMA
        LEFT JOIN pg_catalog.pg_description dsc ON dsc.objoid = c.oid
                                                AND dsc.objsubid = 0
        WHERE tbls.TABLE_SCHEMA NOT IN ('"'"'information_schema'"'"', '"'"'pg_catalog'"'"')
), config AS (
    SELECT array_to_string(
                      array_agg(CONCAT('"{"', '"', '"name":"', conf.name, '"', ',"value":"', replace(conf.setting, '"', E'"'"'), '"}')),
                      ',') AS config_metadata
    FROM pg_settings conf
), views AS (
    SELECT array_to_string(array_agg(CONCAT('"{"', '"', '"schema":"', views.schemaname::TEXT,
                      '","view_name":"', viewname::TEXT,
                      '","view_definition":""}')),
                      ',') AS views_metadata
    FROM pg_views views
    WHERE views.schemaname NOT IN ('"'"'information_schema'"'"', '"'"'pg_catalog'"'"')
)
SELECT CONCAT('"{"', '"', '"fk_info": [', COALESCE(fk_metadata, '""'),
                    '], "pk_info": [', COALESCE(pk_metadata, '""'),
                    '], "columns": [', COALESCE(cols_metadata, '""'),
                    '], "indexes": [', COALESCE(indexes_metadata, '""'),
                    '], "tables":[', COALESCE(tbls_metadata, '""'),
                    '], "views":[', COALESCE(views_metadata, '""'),
                    '], "database_name": "', CURRENT_DATABASE(), '", "version": "', '',
              '"}') AS metadata_json_to_import
FROM fk_info, pk_info, cols, indexes_metadata, tbls, config, views;
'

# Execute the query and save to file
OUTPUT_FILE="chartdb_schema_export.json"

if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "$QUERY" -t -A > $OUTPUT_FILE; then
    echo -e "${GREEN}✅ Schema exported successfully to $OUTPUT_FILE${NC}"
    echo ""
    echo -e "${BLUE}📋 Next steps:${NC}"
    echo "1. Open ChartDB at http://localhost:8081"
    echo "2. Create a new diagram or open an existing one"
    echo "3. Click 'Import Database' from the sidebar"
    echo "4. Select 'PostgreSQL' as the database type"
    echo "5. Choose 'Smart Query' as the import method"
    echo "6. Copy the contents of $OUTPUT_FILE into the text area"
    echo "7. Click 'Import'"
    echo ""
    echo -e "${YELLOW}💡 Tip: You can also run this script anytime to update your schema in ChartDB${NC}"
else
    echo -e "${RED}❌ Failed to export schema. Please check your database connection and permissions.${NC}"
    exit 1
fi
