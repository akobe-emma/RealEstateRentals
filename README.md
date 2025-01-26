# RealEstateRentals Smart Contract

This repository contains a Clarity smart contract for managing real estate rentals on the Stacks blockchain. The contract allows a landlord to set rent amounts, register tenants, and handle rent payments and penalties for late payments.

## Contract Features

- **Set Rent Amount**: Allows the owner to set the rent amount.
- **Set Penalty Fee**: Allows the owner to set the penalty fee for late payments.
- **Register Tenant**: Allows the owner to register a tenant.
- **Pay Rent**: Allows the tenant to pay rent.
- **Penalize Late Payments**: Automatically penalizes late payments.
- **View Tenant Ledger**: Allows viewing the ledger of all rent payments.
- **Check Rent Details**: Allows checking the current rent amount and penalty fee.
- **Check Tenant Details**: Allows checking the details of the current tenant.

## Contract Structure

The contract is defined in [contracts/RealEstateRentals.clar](contracts/RealEstateRentals.clar) and includes the following data variables and functions:

### Data Variables

- `owner`: The principal address of the contract owner (landlord).
- `rent-amount`: The rent amount per period (default: 1000 microSTX).
- `penalty-fee`: The penalty fee for late payments.
- `rental-period`: The rental period in seconds (~30 days).
- `tenant`: The currently active tenant (optional principal).
- `last-payment-time`: The timestamp of the last rent payment.
- `rent-ledger`: A map of all rent payments.

### Public Functions

- `set-rent-amount(amount uint)`: Sets the rent amount (owner-only).
- `set-penalty-fee(fee uint)`: Sets the penalty fee (owner-only).
- `register-tenant(tenant principal)`: Registers a new tenant (owner-only).
- `pay-rent()`: Allows the tenant to pay rent.
- `penalize-late-payment()`: Penalizes the tenant for late payment.
- `get-rent-details()`: Returns the current rent amount and penalty fee.
- `get-tenant-details()`: Returns the details of the current tenant.

## Development

### Prerequisites

- Node.js
- npm
- Clarinet

### Setup

1. Clone the repository:
    ```sh
    git clone https://github.com/your-username/RealEstateRentals.git
    cd RealEstateRentals
    ```

2. Install dependencies:
    ```sh
    npm install
    ```

### Running Tests

To run the tests, use the following command:
```sh
npm test

Configuration
The project uses Clarinet for testing and simulating the Stacks blockchain. Configuration files are located in the settings directory.
