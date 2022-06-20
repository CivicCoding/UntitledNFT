//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract ERC721 is
Context,
IERC721,
IERC721Metadata,
IERC721Enumerable,
ERC165
{
    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    uint256 private currentIndex = 0;

    struct AddressData {
        uint256 balance;
        uint256 numberminted;
    }

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
    }


    //mapping from token id to address
    mapping(uint256 => address)private _tokenApproval;

    //mapping from address to Address Data
    mapping(address => AddressData)private _addressData;

    //mapping from token id to TokenOwnerShip
    mapping(uint256 => TokenOwnership)private _tokenOwnerShip;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
    * @dev
   * `maxBatchSize` refers to how much a minter can mint at a time.
   * `collectionSize_` refers to how many tokens are in the collection.
   */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxBatchSize_,
        uint256 collectionSize_
    ) {
        require(
            collectionSize_ > 0,
            "ERC721A: collection must have a nonzero supply"
        );
        require(maxBatchSize_ > 0, "ERC721A: max batch size must be nonzero");
        _name = name_;
        _symbol = symbol_;
        maxBatchSize = maxBatchSize_;
        collectionSize = collectionSize_;
    }

    uint256 internal immutable collectionSize;
    uint256 internal immutable maxBatchSize;

    /**
     * @dev Returns the token collection name.
     */
    function name() external view override returns (string memory){
        return _name;
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view override returns (string memory){
        return _symbol;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view override returns (string memory){
        require(_exists(tokenId),"URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
   * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
   * by default, can be overriden in child contracts.
   */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev Returns the total amount of tokens stored by the contract.
         */
    function totalSupply() public view override returns (uint256){
        return currentIndex;
    }

    /**
    * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
         * Use along with {totalSupply} to enumerate all tokens.
         */
    function tokenByIndex(uint256 index) external view override returns (uint256){
        require(index < totalSupply(),"global index out of bounds");
        return index;
    }

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
         * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
         */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view override returns (uint256){
        require(index < balanceOf(owner),"owner index out of bounds");
        uint256 numMintedSoFar = totalSupply();
        uint256 tokenidsIndex = 0;
        address currOwnerShipAddr = address(0);
        for(uint256 i = 0; i < numMintedSoFar ; i++) {
            TokenOwnership memory ownership = _tokenOwnerShip[i];
            if(ownership.addr != address(0)){
                currOwnerShipAddr = ownership.addr;
            }
            if(currOwnerShipAddr == owner){
                if(tokenidsIndex == index){
                    return i;
                }
                tokenidsIndex ++;
            }
        }
        revert("ERC721A: unable to get token of owner by index");
    }

    /**
      * @dev See {IERC165-supportsInterface}.
   */
    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
    {
        return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        interfaceId == type(IERC721Enumerable).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256 balance){
        require(owner != address(0),"query for 0 address");
        return uint256(_addressData[owner].balance);
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) public view override returns (address owner){
        return ownershipOf(tokenId).addr;
    }

    function ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory){
        require(_exists(tokenId),"owner query for nonexistent token");

        uint256 lowestTokenToCheck;
        if(tokenId > maxBatchSize){
            lowestTokenToCheck = tokenId - maxBatchSize + 1;
        }
        for(uint256 curr = tokenId ; curr >= lowestTokenToCheck ; curr--){
            TokenOwnership memory ownership = _tokenOwnerShip[curr];
            if(ownership.addr != address(0)){
                return ownership;
            }
        }

        revert("ERC721A: unable to determine the owner of token");
    }

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public
    override {
        _transfer(from,to,tokenId);
    }


    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public
    override{
        safeTransferFrom(from,to,tokenId,"");
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public
    override{
        require(from != address(0),"0 address");
        require(to == address(0),"0 address");
        require(
            _exists(tokenId) && _tokenOwnerShip[tokenId].addr == from
            ,"tokenId error"
        );
        require(_tokenOwnerShip[tokenId].addr == from,"");
        _transfer(from,to,tokenId);
        emit Transfer(from, to, tokenId);
    }


    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external override {
        address owner = ERC721.ownerOf(tokenId);
        require(
            _msgSender() == _tokenApproval[tokenId] ||
            _tokenOwnerShip[tokenId].addr == _msgSender()
            ,"dont have approval");
        require(_exists(tokenId),"token does not exist");
        _setApproval(to, tokenId, owner);
    }

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) public override {
        require(operator != _msgSender(),"approval to caller");
        _operatorApprovals[_msgSender()][operator] = _approved;
        emit ApprovalForAll(_msgSender(),operator,_approved);

    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) public view override returns (address operator) {
        require(_exists(tokenId),"token does not exits");
        return address(_tokenApproval[tokenId]);
    }


    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool){
        return _operatorApprovals[owner][operator];
    }


    function _exists(uint256 tokenId) internal view returns (bool){
        return tokenId < currentIndex;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId)
    private
    {
        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
        getApproved(tokenId) == _msgSender() ||
        isApprovedForAll(prevOwnership.addr, _msgSender()));

        require(
            isApprovedOrOwner,
            "ERC721A: transfer caller is not owner nor approved"
        );

        require(
            prevOwnership.addr == from,
            "ERC721A: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721A: transfer to the zero address");

        //clear approval
        _setApproval(address(0),tokenId,from);
        //to:balance++,from balance--
        _addressData[from].balance -= 1;
        _addressData[to].balance += 1;
        _tokenOwnerShip[tokenId] = TokenOwnership(to, uint64(block.timestamp));

        uint256 nextTokenId = tokenId + 1;
        if(_tokenOwnerShip[nextTokenId].addr == address(0)){
            if(_exists(nextTokenId)){
                _tokenOwnerShip[nextTokenId] = TokenOwnership(prevOwnership.addr,prevOwnership.startTimestamp);
            }
        }

        emit Transfer(from, to, tokenId);
    }

    function _setApproval(address to, uint256 tokenId,address owner) internal {
        require( to != address(0),"0 address");
        _tokenApproval[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _numberMinted(address owner) internal view returns (uint256){
        return uint256(_addressData[owner].numberminted);
    }


    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, "");
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
   *
   * Requirements:
   *
   * - there must be `quantity` tokens remaining unminted in the total collection.
   * - `to` cannot be the zero address.
   * - `quantity` cannot be larger than the max batch size.
   *
   * Emits a {Transfer} event.
   */

    function _safeMint(address to, uint256 quantity, bytes memory _data) internal {
        uint256 startTokenId = currentIndex;
        require(to != address(0),"0 address");
        require(!_exists(startTokenId),"token already minted");
        require(quantity < maxBatchSize,"quantity too high");

        AddressData memory addressData = _addressData[to];
        _addressData[to] = AddressData(
            addressData.balance + uint128(quantity),
            addressData.numberminted + uint(quantity)
        );

        _tokenOwnerShip[startTokenId] = TokenOwnership(to, uint64(block.timestamp));

        uint256 updateIndex = startTokenId;

        for(uint256 i = 0 ; i < quantity ; i++){
            emit Transfer(address(0),to,updateIndex);
            updateIndex++;
        }

        currentIndex = updateIndex;
    }
}
