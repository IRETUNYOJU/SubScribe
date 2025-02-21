# SubScribe: Subscription Management Smart Contract

## Overview
SubScribe is a Clarity smart contract designed for managing subscription-based services on the Stacks blockchain. It enables automated subscription payments, service provider management, and secure fund handling with built-in security features.

## Features

### Core Functionality
- **Subscription Creation**: Users can subscribe to services by locking STX tokens
- **Automated Payments**: Smart contract handles periodic payments to service providers
- **Cancellation Management**: Supports subscription cancellation with early termination fees
- **Role-Based Access Control**: Ensures only authorized providers can access specific functions

### Security Features
- Provider authorization system
- Role-based access control
- Input validation and safety checks
- Secure fund management
- Early termination penalties

## Contract Structure

### Data Storage
- **Service Providers Map**: Tracks authorized service providers
- **Subscriptions Map**: Stores subscription details
- **Contract Variables**:
  - `contract-owner`: Administrator address
  - `minimum-subscription-period`: Minimum subscription duration
  - `early-termination-fee`: Penalty for early cancellation

### Core Functions

#### Subscription Management
```clarity
(define-public (create-subscription (provider principal) (amount uint) (duration uint) (interval uint)))
```
Creates a new subscription with specified parameters:
- `provider`: Service provider's address
- `amount`: Payment amount per interval
- `duration`: Total subscription duration
- `interval`: Payment interval

```clarity
(define-public (process-payment (subscriber principal)))
```
Processes payment for a subscriber:
- Only callable by authorized service providers
- Validates subscription status and timing
- Transfers funds to service provider

```clarity
(define-public (cancel-subscription))
```
Cancels active subscription:
- Calculates and applies early termination fees if applicable
- Updates subscription status

#### Provider Management
```clarity
(define-public (register-service-provider (provider principal)))
```
Registers new service providers:
- Only callable by contract owner
- Validates provider status

```clarity
(define-public (remove-service-provider (provider principal)))
```
Removes service provider authorization:
- Only callable by contract owner
- Verifies provider exists

### Read-Only Functions
- `get-subscription`: Returns subscription details
- `get-minimum-period`: Returns minimum subscription period
- `get-contract-owner`: Returns contract administrator address
- `is-service-provider`: Checks if an address is an authorized provider

## Error Codes
- `u1`: Subscription not found
- `u2`: Subscription not active
- `u3`: Payment not due yet
- `u4`: Subscription expired
- `u5`: Invalid amount
- `u6`: Invalid duration
- `u7`: Invalid interval
- `u8`: Duration must be >= interval
- `u9`: Invalid minimum period
- `u10`: Invalid owner transfer
- `u11`: Provider cannot subscribe to own service
- `u13`: Provider already registered
- `u14`: Provider not found
- `u15`: Unauthorized provider
- `u16`: Not the service provider for subscription
- `u17`: Not an authorized service provider
- `u18`: Invalid subscription data

## Security Considerations
1. **Access Control**
   - Only contract owner can manage providers
   - Only authorized providers can process payments
   - Subscribers can only cancel their own subscriptions

2. **Fund Safety**
   - Secure fund locking mechanism
   - Protected payment processing
   - Controlled fund distribution

3. **Data Validation**
   - Input parameter validation
   - Subscription status checks
   - Provider authorization verification


## Testing
Recommended testing scenarios:
1. Subscription creation and validation
2. Payment processing and timing
3. Provider management
4. Cancellation and fee calculation
5. Security boundary testing
6. Error handling verification

## Deployment
1. Deploy contract to Stacks blockchain
2. Initialize contract owner
3. Register initial service providers
4. Set minimum subscription period
5. Verify contract functionality

## Contributing
When contributing to this project:
1. Follow Clarity best practices
2. Maintain security standards
3. Add comprehensive tests
4. Update documentation
5. Follow standard commit guidelines

