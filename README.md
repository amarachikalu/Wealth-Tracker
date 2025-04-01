# Wealth Tracker

A decentralized financial management system that helps users track spending, revenue, and manage their wealth goals on the blockchain.

## Overview

Wealth Tracker is a smart contract platform that enables users to set financial allocations, record transactions across various categories, track revenue from different channels, and monitor their overall financial health. The system provides transparency and accountability through blockchain-based record keeping.

## Features

- **Financial Planning**: Set and manage financial allocations
- **Transaction Tracking**: Record spending across customizable categories
- **Revenue Management**: Track income from various channels
- **Financial Analytics**: Monitor available funds and total revenue
- **Category Management**: Predefined categories for organized financial tracking
- **Plan Reset**: Option to reset financial plans when needed

## Core Functions

### Public Functions

- `set-allocation`: Create or update a financial allocation
- `record-transaction`: Record a spending transaction
- `record-revenue`: Log incoming revenue
- `reset-financial-plan`: Reset all financial data

### Read-Only Functions

- `get-available-funds`: Check remaining available funds
- `get-total-revenue`: View total accumulated revenue
- `get-transaction`: Retrieve details of a specific transaction
- `get-revenue-entry`: Access information about a specific revenue entry
- `get-valid-categories`: List all valid spending categories
- `get-valid-revenue-channels`: List all valid revenue sources

## Categories

### Spending Categories
- essentials
- shelter
- travel
- services
- wellness
- recreation
- other

### Revenue Channels
- employment
- venture
- returns
- contract
- other

## Getting Started

1. Deploy the contract to your blockchain
2. Set your initial financial allocation
3. Begin recording transactions and revenue
4. Monitor your financial progress through the read-only functions

## Security

All financial data is securely stored on the blockchain, ensuring that records cannot be altered retroactively and providing a reliable audit trail of all financial activities.