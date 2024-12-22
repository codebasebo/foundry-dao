# Foundry DAO Project

 A decentralized autonomous organization (DAO) implementation using Foundry.
 It is built using the Solidity programming language and implements on-chain governance features. The DAO allows token holders to propose, vote on, and execute changes to a managed contract.

## Overview

This project demonstrates how to create a DAO using the Foundry development framework.

## Project Structure

### Contracts

- `Box.sol`: A simple contract that can store and retrieve a value, serving as the contract that the DAO will govern.
- `GovernanceToken.sol`: ERC20 token that grants voting rights in the DAO.
- `GovernorContract.sol`: Main governance contract implementing voting mechanisms and proposal lifecycle.
- `TimeLock.sol`: Contract that adds a delay between proposal passage and execution for security.

### Scripts

- `DeployGovernance.s.sol`: Script to deploy governance-related contracts.

### Tests

- `GovernanceTest.t.sol`: Integration tests for the governance system.

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/downloads)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd foundry-dao
```

2. Install dependencies:
```bash
forge install
```

## Usage

Build the project:
```bash
forge build
```

Run tests:
```bash
forge test
```

## License

This project is licensed under the MIT License.