# supplyInvoice
## Introduction
_supplyInvoice_ is an attempt to accelerate secure exchange of information between parties by leverage on the use of smart contracts. By mapping a collection of  orders, invoices and bill of ladings (BL) as a non-fungible token (NFT), this greatly enhances information exchange between different parities.

Coded in Solidity with _OpenZeppelin_ libraries, _supplyInvoice_ provides a secure implementation and allow 3 different parities (buyer, seller and carrier) to complete the procure-to-pay process.

## API calls
A total 13 different API calls are introduced to complete the supply chain procure-to-pay process, from order creation to payment release.

* createOrder
* cancelOrder
* createInvoice
* cancelInvoice
* createLading
* assignTradeTerms
* negotiateTradeTerms
* determineLiability
* confirmShipment
* retrieveInvoice
* queryOrder
* queryInvoice
* queryLading
