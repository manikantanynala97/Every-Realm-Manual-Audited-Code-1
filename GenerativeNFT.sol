//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./SignedExecutor721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract GenerativeNFT is SignedExecutor, Ownable {
    using Strings for uint256;  

    uint256 public totalSupplyLimit;
    uint256 public mintPerTx;
    uint256 public price;
    uint256 public totalSupply = 0; // here total supply is by default zero so no need to put it seperately so here we can save some gas.

    string public baseURI = ""; // here baseURI is by default empty string so need to put it seperately so here we can save some gas.
    bool public isSaleActive = false; // here isSaleActive is by default false so need to put it seperately so here we can save some gas.

    event BaseURIUpdated(string _baseURI);
    event TotalSupplyLimitUpdated(uint256 _totalSupplyLimit);
    event MintPerTxUpdated(uint256 _mintPerTx);
    event PriceUpdated(uint256 _price);
    event Mint(address _user, uint256 quantity);
    event IsSaleActiveUpdated(bool _isSaleActive);

    constructor(string memory _name, string memory _ticker, 
        uint256 _totalSupplyLimit, uint256 _mintPerTx, uint256 _price) 
        ERC721(_name, _ticker) {
        totalSupplyLimit = _totalSupplyLimit;
        mintPerTx = _mintPerTx;
        price = _price;
    }

    function changeBaseURI(string memory _baseURI) external onlyOwner { // In this function we need to have one check ie the _baseURI should be not equal to empty string
        baseURI = _baseURI;
        emit BaseURIUpdated(baseURI); // use _baseURI
    }

    function changeTotalSupplyLimit(uint256 _totalSupplyLimit) external onlyOwner { // In this function we need to have two checks one is the totalsupply cant be equal to zero and also the total supply should be greater than the current total supply
        totalSupplyLimit = _totalSupplyLimit;
        emit TotalSupplyLimitUpdated(totalSupplyLimit); // use _totalSupplyLimit
    }

    function changeMintPerTx(uint256 _mintPerTx) external onlyOwner { // In this function we need to have one check ie the _mintPerTx should be not equal to 0
        mintPerTx = _mintPerTx;
        emit MintPerTxUpdated(mintPerTx); // use _mintPerTx
    }

    function changePrice(uint256 _price) external onlyOwner { // In this function we need to have one check ie the _price should be not equal to 0
        price = _price;
        emit PriceUpdated(price); // use _price
    }

    function mint(uint256 quantity) external payable { // always check the quantity is greater than zero or else the event will be emitted which will affect the protocol logging
        require(quantity + totalSupply < totalSupplyLimit, "mint: Exceeding total collection size."); // In this line put less than or equal to and also use revert and error instead of require to save some gas
        // Only check these if user is not the owner
        if (msg.sender != owner()) {
            require(quantity <= mintPerTx, "mint: Can't mint more NFTs per transaction."); // In this line  use revert and error instead of require to save some gas and also you are giving chance to mint infinte nfts for attackers as it will lead to vulnerability
            require(msg.value ==  quantity * price, "mint: Wrong amount paid."); // In this line  use revert and error instead of require to save some gas
            require(isSaleActive, "mint: Sale is not activated"); // In this line  use revert and error instead of require to save some gas
        }
        for (uint256 i = 0; i < quantity; i++) { // In this line you dont have to declare i=0 by default it is zero and use unchecked ++i to save some more gas
            _safeMint(msg.sender, totalSupply + i); // We use safemint basically for checking that mint will not happen to the msg.sender == contract address and apply reentrancy guard to this function so that they wont be any attack here it wont be a problem because total supply is updated after mint and collision will happen but if the total supply is updated before only then it is a high vulnerability.
        }
        totalSupply = totalSupply + quantity;

        emit Mint(msg.sender, quantity);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance); // use call instead of transfer 
    }

    function tokenURI(uint256 _tokenId) public view override returns(string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        return bytes(baseURI).length > 0 ? 
            string(abi.encodePacked(baseURI, _tokenId.toString())) : "";
    }

    function changeIsSaleActive(bool _isSaleActive) external onlyOwner { // here we are not checking whether the isSaleActive and _isSaleActive are different and if they are same then it is unnesscary protocol logging
        isSaleActive = _isSaleActive;
        emit IsSaleActiveUpdated(isSaleActive); // use _isSaleActive
    }
}
