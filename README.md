# NM-0062-EVERY-REALM-FINAL REPORT-DO NOT CHANGE

**Repo:** https://github.com/rrealmdev/erc721-signed-tx-executor

**Commit**: 44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0

https://github.com/rrealmdev/erc721-signed-tx-executor/tree/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0

https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol

https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/SignedExecutor1155.sol

## General

### [Info] Multiple Solidity versions

**File(s)**: [`contracts/*`](https://github.com/rrealmdev/erc721-signed-tx-executor/tree/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/)

**Description**: 

Both of the `SignedExecutor` contracts use the Solidity version `0.8.17` while the `GenerativeNFT` contract uses the Solidity version `0.8.16`. Using the same Solidity versions throughout a codebase is recommended to improve consistency and reduce the risk of compatibility issues. All contracts also use a floating pragma. Contracts should be deployed using the same compiler version which they have been tested with. Locking the pragma ensures that contracts do not accidentally get deployed using an older compiler version with unfixed bugs.

**Recommendation(s)**: Consider removing the floating pragma and using the same Solidity version for all contracts.

**Status**: Fixed 

**Update from the client**:  Agree. Versions updated to use 0.8.17 across all contracts.

---

## `contracts/GenerativeNFT.sol`

### [Medium] The `mintPerTx` limit can be bypassed

**File(s)**: [`contracts/GenerativeNFT.sol`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: The function `mint(...)` ensures that the number of tokens minted in a single transaction cannot exceed a set limit. The user passes an argument `quantity` to indicate how many tokens should be minted. If `quantity` is greater than `mintPerTx` then the call will revert. This approach does not count the amount of tokens minted in the current transaction, it instead counts the amount minted in the current call. An attacker could deploy a contract which makes multiple separate calls to `mint(...)` where each call would pass a check, even though the total amount of tokens minted in the transaction is higher than the imposed limit.

**Recommendation(s)**: Consider changing the mint limit implementation to track the number of tokens minted across the entire transaction rather than per unique call.

**Status**: Fixed 

**Update from the client**: Agree. `mintPertx` to be removed.

---
### [Medium] Total collection size cannot reach maximum

**File(s)**: [`contracts/GenerativeNFT`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: In the function `mint(...)`, the total supply check uses the less-than (`<`) operator to ensure that the total supply will never reach `totalSupplyLimit`. 

In the function `mint(...)` a check is done to ensure that the amount to be minted will not cause the total supply to exceed the total supply limit. This check is done with the less-than (`<`) operator, which means that `totalSupply` will never reach `totalSupplyLimit`. The total supply check is shown below:

```solidity
function mint(uint256 quantity) external payable {
    require(quantity + totalSupply < totalSupplyLimit, "mint: Exceeding total collection size.");
    ...
}
```

For example, with collection size `totalSupplyLimit = 100` and current `totalSupply = 99`, calling `mint(quantity = 1)` will be reverted.

**Recommendation(s)**: Consider changing `<` to `<=` in the total supply check.

**Status**: Fixed

**Update from the client**: Agree. Check if `totalSupply` is greater than or equal to `totalSupply` to be implemented.

---
### [Low] Missing input validation for `mintPerTx`

**File(s)**: [`contracts/GenerativeNFT`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: The storage variable `mintPerTx` can be set in the constructor and in the function `changeMintPerTx(...)`. When setting `mintPerTx` there should be a check to ensure the new value cannot be zero.

**Recommendation(s)**: Consider adding input validation to the function `changeMintPerTx(...)` to prevent a new value that is zero from being set. To reduce repeated code, the constructor can call `changeMintPerTx(...)` to use its input validation.

**Status**: Fixed 

**Update from the client**: Agree. `mintPerTx` functionality to be removed due to lack of utility.

---
### [Low] Missing input validation for `totalSupplyLimit`

**File(s)**: [`contracts/GenerativeNFT`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: The storage variable `totalSupplyLimit` can be set in the constructor and in the function `changeTotalSupplyLimit(...)`. When setting `totalSupplyLimit` there should be two checks: a) The new value cannot be zero; b) The new value cannot be less than the current total supply.

**Recommendation(s)**: Consider adding input validation to the function `changeTotalSupplyLimit(...)` to prevent a new value that is zero or less than the current total supply. To reduce repeated code, the constructor can call `changeTotalSupplyLimit(...)` to use its input validation.

**Status**: Fixed 

**Update from the client**: Agree. Validate `totalSupplyLimit` to be greater than current supply to be implemented.

---
### [Low] Missing input validation in `mint(...)`

**File(s)**: [`contracts/GenerativeNFT`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: There is no check in the function `mint(...)` if the argument `quantity` is higher than 0. When calling this function with `quantity` of zero, no tokens will be minted but an event will still be emitted which can affect protocol logging.

**Recommendation(s)**: Consider adding a check to ensure that `quantity` is not 0.

**Status**: Fixed 

**Update from the client**: Agree. Validating number to mint to be greater than zero to be implemented.

---
### [Low] Sale parameters should be immutable while sale is active

**File(s)**: [`contracts/GenerativeNFT.sol`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: The functions `changeTotalSupplyLimit(...)`, `changeMintPerTx(...)` and `changePrice(...)` are callable by the contract owner while a sale is active. To promote trust from users it should not be possible for sale parameters to be modified during a sale, as while a sale is active it should be guaranteed that all users who mint will be under the same conditions as everybody else.

**Recommendation(s)**: Consider implementing a feature to prevent sale parameters from being changed while a sale is live. It should be noted that there should be some restriction on the ability to enable and disable the sale as a simple check to see if a sale is active upon a parameter change can be bypassed by disabling the sale, changing the parameter, then enabling the sale again. 

**Status**: Fixed 

**Update from the client**: Agree. Price and changes to be disabled while sale is active, total supply to be greater than current supply, and `mintPerTx` to be removed.

---
### [Low] `transfer(...)` can fail to send Ether

**File(s)**: [`contracts/GenerativeNFT`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: In the function `withdraw(...)`, `transfer(...)` is used to send the contract balance. However, `transfer(...)` forwards a fixed amount of gas which is 2,300. This may not be enough to send Ether if the recipient is a contract or gas costs change. Further details can be found [here](https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/)

**Recommendation(s)**: Consider using `call(...)` instead of `transfer(...)` when sending Ether.

**Status**: Fixed 

**Update from the client**: Agree. Call to be used in place - and check return value is successful.

---
### [Info] Events emitted using storage variable data

**File(s)**: [`contracts/GenerativeNFT.sol`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: Some event emissions in the `GenerativeNFT` contract use a storage variable as an argument. This will use an extra `SLOAD` opcode costing `100` gas as it does a "warm access" to an already-written storage variable. In the "change" functions (such as `changePrice(...)`) the calldata argument can be used instead of the storage variable when emitting the event to save this `100` gas.

**Recommendation(s)**: Consider emitting an event using calldata rather than the storage variable to save gas. An example is shown below:

```solidity
function changePrice(uint256 _price) external onlyOwner {
    price = _price;
    emit PriceUpdated(_price);
}
```

**Status**: Fixed 

**Update from the client**: Agree. Use `calldata` in lieu of memory to be implemented.

---
### [Info] Missing re-entrancy guard in `mint(...)`

**File(s)**: [`contracts/GenerativeNFT`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: The function `mint(...)` uses `_safeMint(...)` to mint tokens to the caller address. If the recipient of the mint is a contract address, `_safeMint(...)` will do a callback to the recipient to confirm that they are able to accept the to-be-minted tokens. This opens the opportunity for re-entrancy back into the mint function. Currently this does not pose a risk as the `totalSupply` is updated after all minting is complete, so there will be a `tokenId` collision when minting which will revert. Since this code is currently in development and the function may change, it could be possible in the future for the `totalSupply` to be updated before which would allow for re-entrancy.

**Recommendation(s)**: Consider adding re-entrancy guards to the function `mint(...)` to prevent malicious use of the callback from `_safeMint(...)`.

**Status**: Fixed 

**Update from the client**: Agree. Reentrant protection to be implemented.

---
### [Info] Redundant zero initialization on storage variables

**File(s)**: [`contracts/GenerativeNFT`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: The storage variables `totalSupply`, `isSaleActive` and `baseURI` are already set to default values upon contract initialization. These variables are then set to their default values again, costing more gas than necessary.

**Recommendation(s)**: Consider removing the unnecessary initialization for the variables `totalSupply`, `isSaleActive` and `baseURI`.

**Status**: Fixed 

**Update from the client**: Agree. Initialization of null values to be removed.

---
### [Best Practices] `changeIsSaleActive` might not work as intended

**File(s)**: [`contracts/GenerativeNFT.sol`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/GenerativeNFT.sol)

**Description**: The function `changeIsSaleActive(...)` does not check if the argument `_isSaleActive` is different to the `isSaleActive` storage variable. This can cause an unnecessary event emission and affect protocol logging.

**Recommendation(s)**: Consider creating two functions for setting the sale state: `startSale(...)` and `endSale(...)`. This will make setting sale states a much more straightforward process and prevent unnecessary event emission.

**Status**: Fixed 

**Update from the client**: Agree. Validate sale state is not the current state to be implemented.

---

## `contracts/SignedExecutor721.sol`

### [High] Not guarding against `Signature Replay Attacks`

**File(s)**: [`contracts/SignedExecutor721.sol`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/SignedExecutor721.sol)

**Description**: The signatures used in `executeSetIfSignatureMatch(...)` do not make use of a nonce. This opens up the possibility for signature replay attacks as long as the attack is done within the timeframe of the specified deadline.

From the [EIP-712 Standard](https://eips.ethereum.org/EIPS/eip-712): "This standard is only about signing messages and verifying signatures. In many practical applications, signed messages are used to authorize an action, for example an exchange of tokens. It is very important that implementers make sure the application behaves correctly when it sees the same signed message twice. For example, the repeated message should be rejected or the authorized action should be idempotent. How this is implemented is specific to the application and out of scope for this standard."

**Potential Attack**: A signature replay attack on an ERC-721 token transfer can allow the same token to be transferred again. If some token was transferred from a user is sent back to their own address, as long as the current time is within the specified deadline this transfer can be successfully executed again without the users permission. An example scenario is described below:

1. Alice wants to sell Bob an NFT for the price of 5 Ether.
2. Alice signs a message to transfer an NFT from her wallet to Bob's wallet with a 24 hour deadline.
3. A trusted third party acts as a middleman and executes the trade.
4. After the trade Bob decides to put the NFT on sale in some marketplace.
5. Alice decides to purchase that NFT back (this purchase is done within the 24 hour deadline).
6. Bob can now use Alice's previous signature to transfer the NFT from Alice again for free.

**Recommendation(s)**: Consider adopting a mechanism to prevent signature replay attacks.

**Status**: Fixed

**Update from the client**: Agree and highest priority fix to be implemented. Implementation will use a mapping of address to array of transaction hashes, checking if hash has been seen before executing.

---

## `contracts/SignedExecutor1155.sol`

### [Critical] Not guarding against `Signature Replay Attacks`

**File(s)**: [`contracts/SignedExecutor1155.sol`](https://github.com/rrealmdev/erc721-signed-tx-executor/blob/44f3b9f76b5300dc371cc2d547a7a9b4bf3313b0/contracts/SignedExecutor1155.sol)

**Description**: The signatures used in `executeSetIfSignatureMatch(...)` do not make use of a nonce. This opens up the possibility for signature replay attacks as long as the attack is done within the timeframe of the specified deadline.

From the [EIP-712 Standard](https://eips.ethereum.org/EIPS/eip-712): "This standard is only about signing messages and verifying signatures. In many practical applications, signed messages are used to authorize an action, for example an exchange of tokens. It is very important that implementers make sure the application behaves correctly when it sees the same signed message twice. For example, the repeated message should be rejected or the authorized action should be idempotent. How this is implemented is specific to the application and out of scope for this standard."

**Potential Attack**: A signature replay attack on an ERC-1155 is more severe than on an ERC-721 token as explained earlier. This is because an ERC-1155 can act as an ERC-20 token. If a user has 1000 tokens but creates a signature to transfer 100 tokens, this message can be repeated 10 times to transfer the entire amount to the recipient. This means that any token transfer done through `executeSetIfSignatureMatch(...)` can have its signature replayed to continuously transfer tokens from the sender until the underlying `transfer(...)` function fails due to a lack of funds.

**Recommendation(s)**: Consider adopting a mechanism to prevent signature replay attacks.

**Status**: Fixed

**Update from the client**: Agree and highest priority fix to be implemented. Implementation will use a mapping of address to array of transaction hashes, checking if hash has been seen before executing.

---

