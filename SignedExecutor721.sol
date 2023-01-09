// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;   // dont use floating decimals as well as use same version for all contracts involving.

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

abstract contract SignedExecutor is ERC721, EIP712 {

    constructor() EIP712("ERC721 Signed Executor", "1") {}

    function executeSetIfSignatureMatch(
        bytes calldata signature,
        address sender,
        uint256 deadline,
        address from,
        address to,
        uint256 tokenId
    ) external {

        // 1. Require sender to be valid address and deadline has not elapsed

        require(sender != address(0), "SignedExecutor: Invalid sender");
        require(
            block.timestamp < deadline,
            "SignedExecutor: Transaction expired"
        );

        // 2. Check if the signature matches transferFrom

        bytes32 transferHashStruct = keccak256(
            abi.encode(
                keccak256(
                    "transferFrom(address sender,address from,address to,uint256 tokenId,uint256 deadline)"
                ),
                sender,
                from,
                to,
                tokenId,
                deadline
            )
        );

        bytes32 digest = _hashTypedDataV4(transferHashStruct);

        if (SignatureChecker.isValidSignatureNow(sender, digest, signature)) {
            require(
                _isApprovedOrOwner(sender, tokenId),
                "SignedExecutor: Sender is unauthorized"
            );
            _transfer(from, to, tokenId);
            return;
        }

        // 3. Check if the signature matches setApprovalForAll

        bytes32 approvalHashStruct = keccak256(
            abi.encode(
                keccak256(
                    "setApprovalForAll(address sender,address from,address to,uint256 deadline)"
                ),
                sender,
                from,
                to,
                deadline
            )
        );

        digest = _hashTypedDataV4(approvalHashStruct);

        if (SignatureChecker.isValidSignatureNow(sender, digest, signature)) {
            require(sender == from, "SignedExecutor: Sender is unauthorized");
            _setApprovalForAll(from, to, true);
            return;
        }

        // 4. If signature matches neither, revert

        revert("SignedExecutor: invalid signature");
    }
}
