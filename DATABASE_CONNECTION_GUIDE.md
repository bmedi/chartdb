# ChartDB Database Connection Guide

## Overview

ChartDB provides powerful database schema import capabilities that allow you to connect to local databases and automatically pull database schemas. While ChartDB doesn't store connection settings permanently, it provides multiple methods to import database schemas.

## Supported Database Types

ChartDB supports the following database types:
- **PostgreSQL** (including Supabase and TimescaleDB editions)
- **MySQL** (including MariaDB)
- **SQLite**
- **SQL Server**
- **ClickHouse**
- **CockroachDB**
- **Oracle**

## Import Methods

ChartDB offers three main import methods:

### 1. Smart Query (Recommended)
The most powerful method that connects directly to your database and extracts metadata.

### 2. DDL Import
Import from SQL DDL scripts (CREATE TABLE statements, etc.)

### 3. DBML Import
Import from DBML (Database Markup Language) files

## Connecting to Local PostgreSQL

### Method 1: Using psql (Command Line)

1. **Open ChartDB** at `http://localhost:8081`
2. **Create a new diagram** or open an existing one
3. **Click "Import Database"** from the sidebar
4. **Select "PostgreSQL"** as the database type
5. **Choose "Smart Query"** as the import method
6. **Run the provided query** in your terminal:

```bash
# Replace with your actual connection details
psql -h localhost -p 5432 -U your_username -d your_database_name -c "
[ChartDB will provide the exact query here]
" -t -A > output.json
```

7. **Copy the contents** of `output.json` into ChartDB
8. **Click "Import"**

### Method 2: Using Database Client

1. **Open your preferred PostgreSQL client** (pgAdmin, DBeaver, etc.)
2. **Connect to your local database**
3. **Run the Smart Query** provided by ChartDB
4. **Copy the JSON output** into ChartDB

### Method 3: Using DDL Scripts

If you have existing DDL scripts:

1. **Export your schema** using `pg_dump`:
```bash
pg_dump -h localhost -p 5432 -U your_username -d your_database_name --schema-only --no-owner --no-privileges > schema.sql
```

2. **In ChartDB**, select "DDL" as the import method
3. **Paste your DDL script** into the editor
4. **Click "Import"**

## Connecting to Other Databases

### MySQL/MariaDB

```bash
# Using mysql command line
mysql -h localhost -P 3306 -u your_username -p your_database_name -e "
[ChartDB will provide the exact query here]
" > output.json
```

### SQLite

```bash
# Using sqlite3 command line
sqlite3 your_database.db "
[ChartDB will provide the exact query here]
" > output.json
```

### SQL Server

```sql
-- Run this query in SQL Server Management Studio or Azure Data Studio
[ChartDB will provide the exact query here]
```

## Setting Up Connection Scripts

To make database connections easier, you can create reusable scripts:

### PostgreSQL Connection Script

Create a file called `connect_postgres.sh`:

```bash
#!/bin/bash

# Configuration
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="your_database"
DB_USER="your_username"

# Run the ChartDB query
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
[ChartDB Smart Query]
" -t -A > chartdb_export.json

echo "Schema exported to chartdb_export.json"
echo "Copy the contents of this file into ChartDB"
```

### MySQL Connection Script

Create a file called `connect_mysql.sh`:

```bash
#!/bin/bash

# Configuration
DB_HOST="localhost"
DB_PORT="3306"
DB_NAME="your_database"
DB_USER="your_username"

# Run the ChartDB query
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "
[ChartDB Smart Query]
" > chartdb_export.json

echo "Schema exported to chartdb_export.json"
echo "Copy the contents of this file into ChartDB"
```

## Docker Integration

If you're running databases in Docker, you can connect from your host machine:

### PostgreSQL in Docker

```bash
# Connect to PostgreSQL running in Docker
psql -h localhost -p 5432 -U postgres -d your_database -c "
[ChartDB Smart Query]
" -t -A > output.json
```

### MySQL in Docker

```bash
# Connect to MySQL running in Docker
mysql -h localhost -P 3306 -u root -p your_database -e "
[ChartDB Smart Query]
" > output.json
```

## Advanced Features

### Schema Filtering

ChartDB's Smart Queries automatically filter out system schemas and tables, focusing on your application data.

### Relationship Detection

The Smart Queries automatically detect:
- Primary keys
- Foreign key relationships
- Indexes
- Views
- Custom types
- Table comments

### Multiple Schema Support

For databases with multiple schemas, ChartDB will:
- Import all user schemas
- Maintain schema relationships
- Organize tables by schema

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Check if your database is running
   - Verify host and port settings
   - Check firewall settings

2. **Authentication Failed**
   - Verify username and password
   - Check database permissions
   - Ensure user has access to the database

3. **Query Timeout**
   - For large databases, the query might take time
   - Consider filtering specific schemas
   - Use DDL import for very large databases

### Performance Tips

1. **For Large Databases**
   - Use DDL import instead of Smart Query
   - Export only specific schemas
   - Use database-specific tools for large exports

2. **For Development**
   - Use Smart Query for real-time schema updates
   - Keep connection scripts handy
   - Use Docker for consistent environments

## Best Practices

1. **Regular Updates**
   - Re-import schema when database changes
   - Keep diagrams in sync with actual database
   - Use version control for schema changes

2. **Documentation**
   - Add comments to tables and columns
   - Use meaningful table and column names
   - Document relationships and constraints

3. **Team Collaboration**
   - Share connection scripts with team
   - Use consistent database naming
   - Document connection procedures

## Example Workflow

1. **Start your local database** (PostgreSQL, MySQL, etc.)
2. **Open ChartDB** at `http://localhost:8081`
3. **Create a new diagram**
4. **Click "Import Database"**
5. **Select your database type**
6. **Choose "Smart Query"**
7. **Run the provided query** in your terminal
8. **Copy the JSON output** into ChartDB
9. **Click "Import"**
10. **Your database schema is now visualized!**

## Next Steps

After importing your schema:
- **Customize the layout** by dragging tables
- **Add relationships** if not detected automatically
- **Export to SQL** for database creation
- **Share diagrams** with your team
- **Generate documentation** from your schema

This workflow allows you to maintain a visual representation of your database schema that stays in sync with your actual database structure.
