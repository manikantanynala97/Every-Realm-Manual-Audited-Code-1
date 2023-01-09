// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

abstract contract SignedExecutor is ERC1155, EIP712 {
    constructor() EIP712("ERC1155 Signed Executor", "1") {}

    function executeSetIfSignatureMatch(
        bytes calldata signature,
        address sender,
        uint256 deadline,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    ) external {
        require(block.timestamp < deadline, "Signed transaction expired");

        bytes32 transferHashStruct = keccak256(
            abi.encode(
                keccak256(
                    "transferFrom(address sender,address from,address to,uint256 tokenId,uint256 amount,uint256 deadline)"
                ),
                sender,
                from,
                to,
                tokenId,
                amount,
                deadline
            )
        );

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

        bytes32 digest = _hashTypedDataV4(transferHashStruct);
        address signer = ECDSA.recover(digest, signature);

        if (signer == sender) {
            require(signer != address(0), "ECDSA: invalid signature");
            require(isApprovedForAll(signer, to), "ECDSA: Signer is unauthorized");
            _safeTransferFrom(from, to, tokenId, amount, "");
            return;
        }

        digest = _hashTypedDataV4(approvalHashStruct);
        signer = ECDSA.recover(digest, signature);

        if (signer == sender) {
            require(signer != address(0), "ECDSA: invalid signature");
            require(signer == from, "ECDSA: Signer is unauthorized");
            _setApprovalForAll(from, to, true);
            return;
        }

        revert("SignedExecutor: invalid signature");
    }
}
