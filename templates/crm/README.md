# CRM Database Schema Templates

This directory contains comprehensive CRM (Customer Relationship Management) database schema templates inspired by the templates available at [chartdb.io/templates](https://chartdb.io/templates).

## Available Templates

### 1. Basic CRM (`basic-crm.json`)
A foundational CRM system with:
- **Companies**: Organization information with contact details
- **People**: Individual contacts with company relationships
- **Opportunities**: Sales opportunities with stages and values
- **Activities**: Task and activity tracking

**Use Case**: Small to medium businesses needing basic CRM functionality.

### 2. Sales CRM (`sales-crm.json`)
A sales-focused CRM with:
- **Leads**: Lead management with scoring and source tracking
- **Deals**: Sales pipeline with stages and probability tracking
- **Sales Activities**: Call, email, and meeting tracking
- **Products**: Product catalog with pricing
- **Deal Products**: Product-line items for deals

**Use Case**: Sales teams needing comprehensive pipeline management.

### 3. Customer Support CRM (`customer-support.json`)
A support-focused system with:
- **Customers**: Customer information and priority levels
- **Support Agents**: Team member management
- **Tickets**: Support ticket tracking with status and priority
- **Ticket Messages**: Communication history
- **Knowledge Base**: Self-service articles
- **Satisfaction Surveys**: Customer feedback tracking

**Use Case**: Customer support teams and helpdesk operations.

### 4. Marketing CRM (`marketing-crm.json`)
A marketing automation system with:
- **Contacts**: Lead and contact management
- **Campaigns**: Marketing campaign tracking
- **Campaign Contacts**: Contact-campaign relationships
- **Marketing Activities**: Email, social media, and other marketing activities
- **Activity Tracking**: Engagement and response tracking
- **Segments**: Customer segmentation for targeted marketing

**Use Case**: Marketing teams needing campaign and lead management.

### 5. Enterprise CRM (`enterprise-crm.json`)
A comprehensive enterprise system with:
- **Organizations**: Company hierarchy and detailed organization data
- **Contacts**: Advanced contact management with decision-making roles
- **Opportunities**: Complex sales opportunity tracking
- **Products**: Product catalog with SKU and cost tracking
- **Opportunity Products**: Product-line items for opportunities
- **Activities**: Comprehensive activity and task management
- **Documents**: File and document management
- **Notes**: Private and public note-taking system

**Use Case**: Large organizations needing advanced CRM capabilities.

## Key Features Across Templates

### Common Relationship Patterns
- **One-to-Many**: Organizations to Contacts, Opportunities to Activities
- **Many-to-Many**: Campaigns to Contacts, Segments to Contacts
- **Self-Referencing**: Organizations can have parent organizations

### Standard Fields
- **Timestamps**: `created_at`, `updated_at` for audit trails
- **Status Tracking**: Various status fields for workflow management
- **Priority Levels**: Priority and importance tracking
- **Foreign Keys**: Proper relationship management

### Industry Standards
- **Lead Scoring**: Numerical scoring systems for lead qualification
- **Pipeline Stages**: Standard sales pipeline stages (prospecting, qualification, proposal, etc.)
- **Activity Types**: Common CRM activity types (call, email, meeting, task)
- **Contact Methods**: Multiple communication channels

## Usage with ChartDB

These templates can be imported into ChartDB to:
1. **Generate Database Schemas**: Create actual database tables
2. **Visualize Relationships**: See entity relationship diagrams
3. **Export SQL**: Generate SQL DDL statements
4. **Document Systems**: Create comprehensive system documentation

## Template Selection Guide

| Business Size | Primary Need | Recommended Template |
|---------------|--------------|---------------------|
| Small Business | Basic contact management | Basic CRM |
| Sales Team | Pipeline management | Sales CRM |
| Support Team | Ticket management | Customer Support CRM |
| Marketing Team | Campaign management | Marketing CRM |
| Enterprise | Comprehensive CRM | Enterprise CRM |

## Customization

Each template can be customized by:
- Adding/removing fields
- Modifying relationships
- Adjusting data types
- Adding business-specific tables
- Implementing custom workflows

## Integration with Ollama

These templates work seamlessly with the Ollama LLM integration in ChartDB, allowing you to:
- Generate natural language descriptions of schemas
- Create SQL queries using natural language
- Get recommendations for schema improvements
- Automate documentation generation
