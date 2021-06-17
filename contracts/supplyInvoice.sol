// SPDX-License-Identifier: AFL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract supplyInvoice is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    using SafeMath for uint256;

    enum invoiceStates {Draft, Issued, Cancelled, Expired, Shipped, Paid}
    enum tradeTerms {EXW, FCA, CPT, CIP, DAP, DPU, DDP, FAS, FOB, CFR, CIF}

    constructor() ERC721("supplyInvoice", "SIV") {}

    // contains necessary information to facilitate communication, payment and successful shipment of goods between the buyer B, seller S and carrier C
    struct order {
        address buyer;
        address seller;
        address carrier;

        uint256 referenceNumber;
        invoiceStates invoiceState;
        tradeTerms tradeTerm;

        string goods;
        uint256 quantity;
        uint256 number;
        uint256 price;

        bool init;
    }

    mapping (uint256 => order) orders;

    // created by B for the initial order and prompts to populate all necessary fields in the order struct to facilitate procurement of goods or services
    function createOrder(address buyer, uint256 referenceNumber, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();

        orders[tokenId].buyer = buyer;
        orders[tokenId].referenceNumber = referenceNumber;
        orders[tokenId].invoiceState = invoiceStates.Draft;
        
        _safeMint(buyer, tokenId);
        _setTokenURI(tokenId, tokenURI);
        
        return tokenId;
    }

    // cancels order
    function cancelOrder(uint256 tokenId) public {
        require (orders[tokenId].invoiceState == invoiceStates.Draft);
        _burn(tokenId);
    }

    // acknowledges the newly created order and prompts S to prepare goods for shipment. Prepare payment for C.
    function createInvoice(address buyer, address seller, uint256 tokenId) public {
        require (_exists(tokenId), "tokenId does not exist!");
        _approve(seller, tokenId);

        orders[tokenId].seller = seller;
        orders[tokenId].invoiceState = invoiceStates.Issued;

        emit invoiceCreation(seller, tokenId);
        safeTransferFrom(buyer, seller, tokenId);
    }

    event invoiceCreation (
        address indexed _from,
        uint256 indexed _token
    );

    // cancels invoice
    function cancelInvoice(uint256 tokenId) public view {
        require (orders[tokenId].invoiceState == invoiceStates.Issued);
        orders[tokenId].invoiceState == invoiceStates.Cancelled;
    }

    // created by C the BL for the shipping process.
    function createLading(address seller, address carrier, uint256 tokenId) public {
        require (_exists(tokenId), "tokenId does not exist!");
        _approve(carrier, tokenId);

        orders[tokenId].carrier = carrier;
        safeTransferFrom(seller, carrier, tokenId);
    }

    // assigns the rules and define liabilities between B and S
    function assignTradeTerms(uint256 tokenId, uint8 tradeTermSelection) public {
        require (orders[tokenId].invoiceState == invoiceStates.Draft); 
        orders[tokenId].tradeTerm = tradeTerms(tradeTermSelection);            
    }

    // negotiates specific liabilities between B and S for negotiable incoterms
    function negotiateTradeTerms(address buyer, address seller, uint256 tokenId) public {
        require(orders[tokenId].invoiceState == invoiceStates.Issued);
        if (orders[tokenId].tradeTerm == tradeTerms.EXW) {
            // liability should completely fall on buyer based on incoterms
        } else if (orders[tokenId].tradeTerm == tradeTerms.FCA || orders[tokenId].tradeTerm == tradeTerms.FAS || orders[tokenId].tradeTerm == tradeTerms.FOB) {
            // check incoterms
        } else if (orders[tokenId].tradeTerm == tradeTerms.CPT || orders[tokenId].tradeTerm == tradeTerms.CIP || orders[tokenId].tradeTerm == tradeTerms.CFR || orders[tokenId].tradeTerm == tradeTerms.CIF) {
            // check incoterms
        } else if (orders[tokenId].tradeTerm == tradeTerms.DAP || orders[tokenId].tradeTerm == tradeTerms.DPU || orders[tokenId].tradeTerm == tradeTerms.DDP) {
            // check incoterms
        }
    }

    // determines the final liability, should an issue with the shipping occur
    function determineLiability(address payable buyer, address payable seller, uint256 tokenId) public {
        require(orders[tokenId].invoiceState == invoiceStates.Issued);
        if (orders[tokenId].tradeTerm == tradeTerms.EXW) {
            // check incoterms
        } else if (orders[tokenId].tradeTerm == tradeTerms.FCA || orders[tokenId].tradeTerm == tradeTerms.FAS || orders[tokenId].tradeTerm == tradeTerms.FOB) {
            // check incoterms
        } else if (orders[tokenId].tradeTerm == tradeTerms.CPT || orders[tokenId].tradeTerm == tradeTerms.CIP || orders[tokenId].tradeTerm == tradeTerms.CFR || orders[tokenId].tradeTerm == tradeTerms.CIF) {
            // check incoterms
        } else if (orders[tokenId].tradeTerm == tradeTerms.DAP || orders[tokenId].tradeTerm == tradeTerms.DPU || orders[tokenId].tradeTerm == tradeTerms.DDP) {
            // check incoterms           
        }
    }

    // confirms the completion of the shipping process, provided S acknowledges receipt of the goods in good order
    function confirmShipment(uint256 tokenId) public {
        require (orders[tokenId].invoiceState == invoiceStates.Issued);
        orders[tokenId].invoiceState == invoiceStates.Shipped;
    }

    // retrieves the invoice and releases payment for B, C and S, upon maturity
    function retrieveInvoice(address payable buyer, address payable seller, address payable carrier, uint256 tokenId) public {
        // require (orders[tokenId].invoiceState == invoiceStates.Shipped);
        // release payment to B, C and S
        orders[tokenId].invoiceState == invoiceStates.Paid;
    }

    // queries the specified order for information. Performed only by B or S
    function queryOrder(address buyer, address seller, uint256 tokenId) public view returns (order memory) {
        require (_exists(tokenId) && orders[tokenId].invoiceState == invoiceStates.Issued, "tokenId does not exist nor invoice is issued!");
        // perform checking if order is indeed owned by B and S
        return orders[tokenId];
    }

    // queries the specified invoice for payment information. Performed by B, C or S. Access is mutually exclusive between these parties
    function queryInvoice(address buyer, address seller, address carrier, uint256 tokenId) public view  returns (order memory) {
        require (_exists(tokenId) && orders[tokenId].invoiceState == invoiceStates.Issued, "tokenId does not exist nor invoice is issued!");
        // perform checking if order is indeed owned by B, C and S
        return orders[tokenId];
    }

    // obtains information regarding the movement of the goods and at which stage is it currently at. Performed only by B or S
    function queryShipment(address buyer, address seller, uint256 tokenId) public view  returns (order memory) {
        require (_exists(tokenId), "tokenId does not exist!");
        // perform checking if order is indeed owned by B and S
        return orders[tokenId];
    }
}